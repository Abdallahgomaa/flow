import 'package:drift/drift.dart';
import 'package:flow/core/database/database.dart';
import 'package:flow/core/money/money_core.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/clock.dart';
import 'package:flow/core/utils/logger.dart';
import 'package:flow/features/settings/domain/business_profile.dart';
import 'package:flow/features/settings/domain/use_cases/load_business_profile.dart';

import '../domain/product.dart';
import '../domain/product_repository.dart';
import '../domain/product_type.dart';

/// Drift-backed [ProductRepository] (`P2-02`).
///
/// Every write wraps the row change **and** its audit entry in a single
/// [UnitOfWork] transaction (AGENTS rule 3), so a stored product can never exist
/// without the audit row that explains it.
///
/// Prices and quantities live in the table as plain integers — minor units and
/// thousandths — because that is the only representation that is exact. The
/// currency is deliberately *not* a column: it is one business setting, so the
/// repository stamps the current shop currency onto the stored minor units when
/// it reads. That is why the shop profile is injected here, and why it is read
/// on every call instead of being cached: changing the currency in the settings
/// screen must immediately change the money every product reports.
final class DriftProductRepository implements ProductRepository {
  /// Creates the repository over its injected collaborators.
  const DriftProductRepository({
    required this.database,
    required this.unitOfWork,
    required this.auditService,
    required this.clock,
    required this.loadBusinessProfile,
  });

  /// Audit entity name recorded for every product change.
  static const String auditEntity = 'products';

  /// The type a stored row falls back to when its slug is unknown.
  ///
  /// The slug is written by this application, so an unknown one means the row
  /// came from somewhere else; treating it as [ProductType.simple] keeps the
  /// catalogue usable instead of failing the whole read over one bad row.
  static const ProductType _fallbackType = ProductType.simple;

  static const String _logName = 'catalog.product_repository';
  static const String _readFailedMessage = 'Could not load the products.';
  static const String _createFailedMessage = 'Could not save the product.';
  static const String _updateFailedMessage = 'Could not save the product.';
  static const String _disableFailedMessage = 'Could not disable the product.';

  /// The database whose `products` table is read and written.
  final AppDatabase database;

  /// Groups every write with its audit entry.
  final UnitOfWork unitOfWork;

  /// Appends the audit entry that explains a write.
  final AuditService auditService;

  /// Supplies the timestamps used when disabling a product.
  final Clock clock;

  /// Reads the shop profile, whose currency every price is expressed in.
  final LoadBusinessProfile loadBusinessProfile;

  @override
  Future<Result<List<Product>>> readAll() async {
    try {
      final Result<Currency> currency = await _shopCurrency();
      final Currency? resolved = currency.valueOrNull;
      if (resolved == null) {
        return Result<List<Product>>.err(currency.failureOrNull!);
      }
      final List<ProductRow> rows =
          await (database.select(database.products)
                ..orderBy(<OrderingTerm Function($ProductsTable)>[
                  ($ProductsTable table) => OrderingTerm.asc(table.name),
                  ($ProductsTable table) => OrderingTerm.asc(table.createdAt),
                ]))
              .get();
      return Result<List<Product>>.ok(
        rows
            .map((ProductRow row) => _toEntity(row, resolved))
            .toList(growable: false),
      );
    } on Object catch (error, stackTrace) {
      AppLogger.instance.error(
        'Failed to read the products',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return Result<List<Product>>.err(
        StorageFailure(
          message: _readFailedMessage,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<Product>> readById(String id) async {
    try {
      final Result<Currency> currency = await _shopCurrency();
      final Currency? resolved = currency.valueOrNull;
      if (resolved == null) {
        return Result<Product>.err(currency.failureOrNull!);
      }
      final ProductRow? row = await _find(id);
      if (row == null) {
        return const Result<Product>.err(_notFound);
      }
      return Result<Product>.ok(_toEntity(row, resolved));
    } on Object catch (error, stackTrace) {
      AppLogger.instance.error(
        'Failed to read product $id',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return Result<Product>.err(
        StorageFailure(
          message: _readFailedMessage,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<Product>> create({
    required Product product,
    required String action,
    Map<String, Object?> payload = const <String, Object?>{},
  }) async {
    try {
      final Failure? failure = await unitOfWork.run<Failure?>(() async {
        final Failure? missing = await _checkReferences(product);
        if (missing != null) {
          return missing;
        }
        await database
            .into(database.products)
            .insert(
              ProductsCompanion.insert(
                id: product.id,
                name: product.name,
                type: product.type.code,
                stockUnitCode: product.stockUnitCode,
                salePriceMinorUnits: product.salePrice.minorUnits,
                createdAt: product.createdAt,
                categoryId: Value<String?>(product.categoryId),
                purchaseUnitCode: Value<String?>(product.purchaseUnitCode),
                costPriceMinorUnits: Value<int?>(product.costPrice?.minorUnits),
                reorderLevelThousandths: Value<int?>(
                  product.reorderLevel?.thousandths,
                ),
              ),
            );
        await auditService.append(
          action: action,
          entity: auditEntity,
          entityId: product.id,
          payload: payload,
        );
        return null;
      });
      return failure == null
          ? Result<Product>.ok(product)
          : Result<Product>.err(failure);
    } on Object catch (error, stackTrace) {
      AppLogger.instance.error(
        'Failed to create product ${product.id}',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return Result<Product>.err(
        StorageFailure(
          message: _createFailedMessage,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<Product>> update({
    required Product product,
    required String action,
    Map<String, Object?> payload = const <String, Object?>{},
  }) async {
    try {
      final Failure? failure = await unitOfWork.run<Failure?>(() async {
        // Re-read inside the transaction: two sessions must not resurrect, or
        // silently overwrite, a product that is no longer there.
        final ProductRow? row = await _find(product.id);
        if (row == null) {
          return _notFound;
        }
        final Failure? missing = await _checkReferences(product);
        if (missing != null) {
          return missing;
        }
        await (database.update(
          database.products,
        )..where(($ProductsTable table) => table.id.equals(product.id))).write(
          ProductsCompanion(
            name: Value<String>(product.name),
            type: Value<String>(product.type.code),
            categoryId: Value<String?>(product.categoryId),
            stockUnitCode: Value<String>(product.stockUnitCode),
            purchaseUnitCode: Value<String?>(product.purchaseUnitCode),
            salePriceMinorUnits: Value<int>(product.salePrice.minorUnits),
            costPriceMinorUnits: Value<int?>(product.costPrice?.minorUnits),
            reorderLevelThousandths: Value<int?>(
              product.reorderLevel?.thousandths,
            ),
            updatedAt: Value<DateTime?>(product.updatedAt),
          ),
        );
        await auditService.append(
          action: action,
          entity: auditEntity,
          entityId: product.id,
          payload: payload,
        );
        return null;
      });
      return failure == null
          ? Result<Product>.ok(product)
          : Result<Product>.err(failure);
    } on Object catch (error, stackTrace) {
      AppLogger.instance.error(
        'Failed to update product ${product.id}',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return Result<Product>.err(
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
        final ProductRow? row = await _find(id);
        if (row == null) {
          return _notFound;
        }
        if (_toEntity(row, Currency.usd).isDisabled) {
          // Nothing changes, so nothing is audited (see the interface docs).
          return null;
        }
        final DateTime now = clock.nowUtc();
        await (database.update(
          database.products,
        )..where(($ProductsTable table) => table.id.equals(id))).write(
          ProductsCompanion(
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
        'Failed to disable product $id',
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

  /// Reads the shop currency, or the failure that stopped the settings read.
  ///
  /// A product's price is meaningless without knowing what the minor units are
  /// in, so an unreadable profile is reported instead of being replaced with a
  /// guess.
  Future<Result<Currency>> _shopCurrency() async {
    final Result<BusinessProfile> profile = await loadBusinessProfile();
    return profile.map(
      (BusinessProfile value) => _currencyByCode(value.currencyCode),
    );
  }

  /// Maps a stored ISO 4217 code onto a known [Currency].
  ///
  /// An unknown code falls back to [Currency.usd], which is
  /// [BusinessProfile.defaultCurrencyCode]: a corrupt setting must not stop the
  /// app from opening (the same rule `BusinessProfile.fromSettings` follows).
  static Currency _currencyByCode(String code) =>
      Currency.predefined.firstWhere(
        (Currency currency) => currency.code == code,
        orElse: () => Currency.usd,
      );

  /// Maps a stored row onto a [Product] (`P2-06`).
  ///
  /// The quick-search repository reads the same rows as this one, so the price
  /// decoding and the two fallbacks (an unknown type, an unknown currency code)
  /// are shared rather than copied: a second copy is a second way for a price to
  /// be read.
  static Product productFromRow(ProductRow row, Currency currency) =>
      _toEntity(row, currency);

  /// The currency this shop's stored prices are read in (`P2-06`).
  static Currency currencyFor(BusinessProfile profile) =>
      _currencyByCode(profile.currencyCode);

  /// Refuses a product that points at a category or a unit that does not exist.
  ///
  /// Checked inside the transaction so the reference cannot vanish between the
  /// check and the write; the foreign key stays the last line of defence.
  Future<Failure?> _checkReferences(Product product) async {
    final String? categoryId = product.categoryId;
    if (categoryId != null && await _findCategory(categoryId) == null) {
      return const NotFoundFailure(
        message: 'The category no longer exists.',
        code: ProductRepository.categoryNotFoundCode,
      );
    }
    if (await _findUnit(product.stockUnitCode) == null) {
      return const NotFoundFailure(
        message: 'The stock unit no longer exists.',
        code: ProductRepository.stockUnitNotFoundCode,
      );
    }
    final String? purchaseUnitCode = product.purchaseUnitCode;
    if (purchaseUnitCode != null && await _findUnit(purchaseUnitCode) == null) {
      return const NotFoundFailure(
        message: 'The purchase unit no longer exists.',
        code: ProductRepository.purchaseUnitNotFoundCode,
      );
    }
    return null;
  }

  static const NotFoundFailure _notFound = NotFoundFailure(
    message: 'That product no longer exists.',
    code: ProductRepository.notFoundCode,
  );

  Future<ProductRow?> _find(String id) => (database.select(
    database.products,
  )..where(($ProductsTable table) => table.id.equals(id))).getSingleOrNull();

  Future<CategoryRow?> _findCategory(String id) => (database.select(
    database.categories,
  )..where(($CategoriesTable table) => table.id.equals(id))).getSingleOrNull();

  Future<UnitRow?> _findUnit(String code) => (database.select(
    database.units,
  )..where(($UnitsTable table) => table.code.equals(code))).getSingleOrNull();

  static Product _toEntity(ProductRow row, Currency currency) => Product(
    id: row.id,
    name: row.name,
    type: ProductType.fromCode(row.type) ?? _fallbackType,
    stockUnitCode: row.stockUnitCode,
    salePrice: Money.fromMinor(row.salePriceMinorUnits, currency),
    createdAt: row.createdAt,
    categoryId: row.categoryId,
    purchaseUnitCode: row.purchaseUnitCode,
    costPrice: row.costPriceMinorUnits == null
        ? null
        : Money.fromMinor(row.costPriceMinorUnits!, currency),
    reorderLevel: row.reorderLevelThousandths == null
        ? null
        : Quantity.thousandths(row.reorderLevelThousandths!),
    disabledAt: row.disabledAt,
    updatedAt: row.updatedAt,
  );
}
