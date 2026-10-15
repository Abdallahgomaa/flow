import 'package:drift/drift.dart';
import 'package:flow/core/database/database.dart';
import 'package:flow/core/money/money_core.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/clock.dart';
import 'package:flow/core/utils/logger.dart';
import 'package:flow/features/settings/domain/business_profile.dart';
import 'package:flow/features/settings/domain/use_cases/load_business_profile.dart';

import '../domain/price_tier.dart';
import '../domain/tier_price_repository.dart';

/// Drift-backed [TierPriceRepository] (`P2-04`).
///
/// Every write wraps the row change **and** its audit entry in a single
/// [UnitOfWork] transaction (AGENTS rule 3), so a stored band can never exist
/// without the audit row that explains it.
///
/// Prices live in the table as plain integers — minor units — because that is the
/// only representation that is exact, and band edges as integer thousandths for
/// the same reason. The currency is deliberately **not** a column: it is one
/// business setting, so the repository stamps the current shop currency onto the
/// stored minor units when it reads. That is why the shop profile is injected
/// here, and why it is read on every call instead of being cached: changing the
/// currency in the settings screen must immediately change the money every band
/// reports.
///
/// Duplicates are enforced in two places on purpose. Inside the transaction the
/// repository checks whether the product already prices that tier from the same
/// quantity, so the caller gets a clean [ConflictFailure] it can explain instead
/// of a database exception; the table's `UNIQUE` constraint stays the last line of
/// defence, so no writer — not even a future one that forgets the check — can
/// create an ambiguous pair of bands.
final class DriftTierPriceRepository implements TierPriceRepository {
  /// Creates the repository over its injected collaborators.
  const DriftTierPriceRepository({
    required this.database,
    required this.unitOfWork,
    required this.auditService,
    required this.clock,
    required this.loadBusinessProfile,
  });

  /// Audit entity name recorded for every price band change.
  static const String auditEntity = 'price_tiers';

  /// The tier an unrecognised stored slug falls back to.
  ///
  /// A row written by a newer build that knows more tiers, then opened by this
  /// one, must still be readable: the band is real money, and hiding it would
  /// silently drop a price. Treating it as retail keeps the shop selling while
  /// the anomaly stays visible in the audit trail.
  static const PriceTier _fallbackTier = PriceTier.retail;

  static const String _logName = 'catalog.tier_price_repository';
  static const String _readFailedMessage = 'Could not load the prices.';
  static const String _createFailedMessage = 'Could not save the price.';
  static const String _updateFailedMessage = 'Could not save the price.';
  static const String _disableFailedMessage = 'Could not disable the price.';

  /// The database whose `price_tiers` table is read and written.
  final AppDatabase database;

  /// Groups every write with its audit entry.
  final UnitOfWork unitOfWork;

  /// Appends the audit entry that explains a write.
  final AuditService auditService;

  /// Supplies the timestamps used when disabling a band.
  final Clock clock;

  /// Reads the shop profile, which decides what the stored minor units mean.
  final LoadBusinessProfile loadBusinessProfile;

  @override
  Future<Result<List<TierPrice>>> readForProduct(String productId) async {
    try {
      final Result<Currency> currency = await _shopCurrency();
      final Currency? resolved = currency.valueOrNull;
      if (resolved == null) {
        return Result<List<TierPrice>>.err(currency.failureOrNull!);
      }
      final List<PriceTierRow> rows =
          await (database.select(database.priceTiers)
                ..where(
                  ($PriceTiersTable table) => table.productId.equals(productId),
                )
                ..orderBy(<OrderingTerm Function($PriceTiersTable)>[
                  ($PriceTiersTable table) => OrderingTerm.asc(table.tier),
                  ($PriceTiersTable table) =>
                      OrderingTerm.asc(table.minQuantityThousandths),
                ]))
              .get();
      return Result<List<TierPrice>>.ok(
        rows
            .map((PriceTierRow row) => _toEntity(row, resolved))
            .toList(growable: false),
      );
    } on Object catch (error, stackTrace) {
      AppLogger.instance.error(
        'Failed to read the prices of product $productId',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return Result<List<TierPrice>>.err(
        StorageFailure(
          message: _readFailedMessage,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<TierPrice>> readById(String id) async {
    try {
      final Result<Currency> currency = await _shopCurrency();
      final Currency? resolved = currency.valueOrNull;
      if (resolved == null) {
        return Result<TierPrice>.err(currency.failureOrNull!);
      }
      final PriceTierRow? row = await _find(id);
      if (row == null) {
        return const Result<TierPrice>.err(_notFound);
      }
      return Result<TierPrice>.ok(_toEntity(row, resolved));
    } on Object catch (error, stackTrace) {
      AppLogger.instance.error(
        'Failed to read price band $id',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return Result<TierPrice>.err(
        StorageFailure(
          message: _readFailedMessage,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<TierPrice>> create({
    required TierPrice tierPrice,
    required String action,
    Map<String, Object?> payload = const <String, Object?>{},
  }) async {
    try {
      final Failure? failure = await unitOfWork.run<Failure?>(() async {
        // Checked inside the transaction so the product cannot vanish between the
        // check and the insert; the foreign key stays the last line of defence.
        final Failure? missing = await _checkProduct(tierPrice.productId);
        if (missing != null) {
          return missing;
        }
        // The duplicate check lives here, not in the caller, so two writers
        // cannot both pass it.
        final Failure? duplicate = await _checkBand(
          productId: tierPrice.productId,
          tier: tierPrice.tier,
          minQuantityThousandths: tierPrice.minQuantity.thousandths,
        );
        if (duplicate != null) {
          return duplicate;
        }
        await database
            .into(database.priceTiers)
            .insert(
              PriceTiersCompanion.insert(
                id: tierPrice.id,
                productId: tierPrice.productId,
                tier: tierPrice.tier.code,
                priceMinorUnits: tierPrice.price.minorUnits,
                createdAt: tierPrice.createdAt,
                minQuantityThousandths: Value<int>(
                  tierPrice.minQuantity.thousandths,
                ),
              ),
            );
        await auditService.append(
          action: action,
          entity: auditEntity,
          entityId: tierPrice.id,
          payload: payload,
        );
        return null;
      });
      return failure == null
          ? Result<TierPrice>.ok(tierPrice)
          : Result<TierPrice>.err(failure);
    } on Object catch (error, stackTrace) {
      AppLogger.instance.error(
        'Failed to create price band ${tierPrice.id}',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return Result<TierPrice>.err(
        StorageFailure(
          message: _createFailedMessage,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<TierPrice>> update({
    required TierPrice tierPrice,
    required String action,
    Map<String, Object?> payload = const <String, Object?>{},
  }) async {
    try {
      final Failure? failure = await unitOfWork.run<Failure?>(() async {
        // Re-read inside the transaction: two sessions must not silently
        // overwrite a band that is no longer there.
        final PriceTierRow? row = await _find(tierPrice.id);
        if (row == null) {
          return _notFound;
        }
        final Failure? missing = await _checkProduct(tierPrice.productId);
        if (missing != null) {
          return missing;
        }
        final Failure? duplicate = await _checkBand(
          productId: tierPrice.productId,
          tier: tierPrice.tier,
          minQuantityThousandths: tierPrice.minQuantity.thousandths,
          excludingId: tierPrice.id,
        );
        if (duplicate != null) {
          return duplicate;
        }
        await (database.update(
              database.priceTiers,
            )..where(($PriceTiersTable table) => table.id.equals(tierPrice.id)))
            .write(
              PriceTiersCompanion(
                priceMinorUnits: Value<int>(tierPrice.price.minorUnits),
                minQuantityThousandths: Value<int>(
                  tierPrice.minQuantity.thousandths,
                ),
                updatedAt: Value<DateTime?>(tierPrice.updatedAt),
              ),
            );
        await auditService.append(
          action: action,
          entity: auditEntity,
          entityId: tierPrice.id,
          payload: payload,
        );
        return null;
      });
      return failure == null
          ? Result<TierPrice>.ok(tierPrice)
          : Result<TierPrice>.err(failure);
    } on Object catch (error, stackTrace) {
      AppLogger.instance.error(
        'Failed to update price band ${tierPrice.id}',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return Result<TierPrice>.err(
        StorageFailure(
          message: _updateFailedMessage,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<void>> disable({
    required String id,
    required String action,
    Map<String, Object?> payload = const <String, Object?>{},
  }) async {
    try {
      final Failure? failure = await unitOfWork.run<Failure?>(() async {
        final PriceTierRow? row = await _find(id);
        if (row == null) {
          return _notFound;
        }
        if (_toEntity(row, Currency.usd).isDisabled) {
          // Nothing changes, so nothing is audited (see the interface docs).
          return null;
        }
        final DateTime now = clock.nowUtc();
        await (database.update(
          database.priceTiers,
        )..where(($PriceTiersTable table) => table.id.equals(id))).write(
          PriceTiersCompanion(
            disabledAt: Value<DateTime?>(now),
            updatedAt: Value<DateTime?>(now),
          ),
        );
        await auditService.append(
          action: action,
          entity: auditEntity,
          entityId: id,
          payload: payload,
        );
        return null;
      });
      return failure == null
          ? const Result<void>.ok(null)
          : Result<void>.err(failure);
    } on Object catch (error, stackTrace) {
      AppLogger.instance.error(
        'Failed to disable price band $id',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return Result<void>.err(
        StorageFailure(
          message: _disableFailedMessage,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  static const NotFoundFailure _notFound = NotFoundFailure(
    message: 'That price band no longer exists.',
    code: TierPriceRepository.notFoundCode,
  );

  /// Refuses the write when the product it names is gone.
  ///
  /// A band prices a product, so a band pointing at nothing is meaningless and the
  /// foreign key would reject it anyway; checking here turns the raw database error
  /// into a failure the caller can explain.
  Future<Failure?> _checkProduct(String productId) async {
    if (await _findProduct(productId) == null) {
      return const NotFoundFailure(
        message: 'The product no longer exists.',
        code: TierPriceRepository.productNotFoundCode,
      );
    }
    return null;
  }

  /// Refuses the write when the same tier is already priced from the same
  /// quantity.
  ///
  /// [excludingId] lets an edit ignore the row it is rewriting, so a band does not
  /// collide with itself.
  Future<Failure?> _checkBand({
    required String productId,
    required PriceTier tier,
    required int minQuantityThousandths,
    String? excludingId,
  }) async {
    final PriceTierRow? existing = await _findBand(
      productId: productId,
      tier: tier,
      minQuantityThousandths: minQuantityThousandths,
      excludingId: excludingId,
    );
    if (existing == null) {
      return null;
    }
    return const ConflictFailure(
      message: 'That tier already has a price starting at this quantity.',
      code: TierPriceRepository.duplicateBandCode,
    );
  }

  /// Reads the shop currency, or the reason it could not be read.
  ///
  /// A band's price is meaningless without knowing what the minor units are in, so
  /// an unreadable profile is reported instead of being replaced with a guess.
  Future<Result<Currency>> _shopCurrency() async {
    final Result<BusinessProfile> profile = await loadBusinessProfile();
    return profile.map(
      (BusinessProfile value) => _currencyByCode(value.currencyCode),
    );
  }

  /// Maps a stored currency code to a [Currency], defaulting to USD.
  static Currency _currencyByCode(String code) =>
      Currency.predefined.firstWhere(
        (Currency currency) => currency.code == code,
        orElse: () => Currency.usd,
      );

  Future<PriceTierRow?> _find(String id) => (database.select(
    database.priceTiers,
  )..where(($PriceTiersTable table) => table.id.equals(id))).getSingleOrNull();

  /// Finds the band that prices one tier of one product from one quantity.
  Future<PriceTierRow?> _findBand({
    required String productId,
    required PriceTier tier,
    required int minQuantityThousandths,
    String? excludingId,
  }) {
    final SimpleSelectStatement<$PriceTiersTable, PriceTierRow> query =
        database.select(database.priceTiers)..where(
          ($PriceTiersTable table) =>
              table.productId.equals(productId) &
              table.tier.equals(tier.code) &
              table.minQuantityThousandths.equals(minQuantityThousandths),
        );
    if (excludingId != null) {
      query.where(
        ($PriceTiersTable table) => table.id.equals(excludingId).not(),
      );
    }
    return query.getSingleOrNull();
  }

  Future<ProductRow?> _findProduct(String id) => (database.select(
    database.products,
  )..where(($ProductsTable table) => table.id.equals(id))).getSingleOrNull();

  TierPrice _toEntity(PriceTierRow row, Currency currency) => TierPrice(
    id: row.id,
    productId: row.productId,
    tier: PriceTier.fromCode(row.tier) ?? _fallbackTier,
    price: Money.fromMinor(row.priceMinorUnits, currency),
    minQuantity: Quantity.thousandths(row.minQuantityThousandths),
    createdAt: row.createdAt,
    disabledAt: row.disabledAt,
    updatedAt: row.updatedAt,
  );
}
