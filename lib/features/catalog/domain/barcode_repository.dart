import 'package:flow/core/result/result.dart';

import 'barcode.dart';

/// The door to the stored barcode labels (interface first, binding rule 9).
///
/// Every write here is one atomic, audited unit of work: the row change and its
/// audit entry commit together, or not at all (binding rule 3).
abstract interface class BarcodeRepository {
  /// Failure code: no label with that id exists.
  static const String notFoundCode = 'barcode.notFound';

  /// Failure code: the code is already registered to a product.
  ///
  /// The caller resolves the conflict through [readByCode], which hands back the
  /// label that owns the code together with the product it points at. That is
  /// how the duplicate is rejected **with a link to the existing product**
  /// (FR-INV-011) without needing a failure type that carries the id: `Failure`
  /// in `core/result` is a sealed hierarchy whose subtypes are final, so a
  /// feature may not invent one of its own.
  static const String alreadyLinkedCode = 'barcode.alreadyLinked';

  /// Failure code: the product the label points at is gone.
  static const String productNotFoundCode = 'barcode.productNotFound';

  /// Every label of one product, retired ones included.
  ///
  /// Retired labels come back on purpose: a receipt or a stock movement from
  /// last year has to keep resolving, and the product screen greys them out.
  Future<Result<List<Barcode>>> readForProduct(String productId);

  /// The active label carrying [code], or [notFoundCode].
  ///
  /// This is the scan path, so it only answers for live labels: a retired code
  /// is reserved to the product it used to identify and must not be handed to a
  /// new scan.
  Future<Result<Barcode>> readByCode(String code);

  /// One label by its identity, retired ones included.
  Future<Result<Barcode>> readById(String id);

  /// Stores a new label.
  ///
  /// Refuses with [alreadyLinkedCode] when the code is already registered —
  /// checked inside the transaction, so two writers cannot both pass the check;
  /// the `UNIQUE` constraint on the column is the last line of defence.
  Future<Result<Barcode>> create({
    required Barcode barcode,
    required String action,
    Map<String, Object?> payload = const <String, Object?>{},
  });

  /// Retires a label.
  ///
  /// The row stays, because documents already printed against it must keep
  /// resolving; disabling an already disabled label is a no-op that is not
  /// audited. Retired codes are not re-registerable: re-enabling is the way back.
  Future<Result<void>> disable({
    required String id,
    required String action,
    Map<String, Object?> payload = const <String, Object?>{},
  });
}
