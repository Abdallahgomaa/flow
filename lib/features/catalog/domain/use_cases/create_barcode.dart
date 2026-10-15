import 'package:flow/core/money/money_core.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/clock.dart';
import 'package:flow/core/utils/uuid_v7.dart';

import '../barcode.dart';
import '../barcode_repository.dart';
import '../barcode_validation.dart';

/// Registers a scannable label for a product (`P2-03`).
///
/// Identity (`id`, `created_at`) is decided here rather than in the database
/// layer, so the same [Clock] that stamps the row also seeds the UUID v7 that
/// orders it: identifiers and timestamps never disagree (the rule the other
/// catalogue use cases follow).
///
/// The use case takes raw fields, not a ready-made [Barcode], because the caller
/// does not know the id or the creation time.
final class CreateBarcode {
  /// Creates the use case.
  const CreateBarcode(this._repository, this._idGenerator, this._clock);

  final BarcodeRepository _repository;
  final UuidV7Generator _idGenerator;
  final Clock _clock;

  /// The audit action recorded for a new label.
  static const String auditAction = 'barcode.created';

  /// Executes the use case.
  ///
  /// [multiplier] defaults to one stock unit, which is what a label printed on
  /// a single item means; a carton label passes its own count.
  Future<Result<Barcode>> call({
    required String code,
    required String productId,
    Quantity multiplier = Barcode.plainUnitMultiplier,
  }) async {
    final Failure? invalid = BarcodeValidation.validate(
      code: code,
      productId: productId,
      multiplier: multiplier,
    );
    if (invalid != null) {
      return Result<Barcode>.err(invalid);
    }

    final Barcode barcode = Barcode(
      id: _idGenerator.next(),
      code: BarcodeValidation.normaliseCode(code),
      productId: productId.trim(),
      multiplier: multiplier,
      createdAt: _clock.nowUtc(),
    );

    return _repository.create(
      barcode: barcode,
      action: auditAction,
      payload: barcode.toAuditPayload(),
    );
  }
}
