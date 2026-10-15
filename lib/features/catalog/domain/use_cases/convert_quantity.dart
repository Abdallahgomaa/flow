import 'package:flow/core/money/money_core.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';

import '../unit.dart';
import '../unit_converter.dart';
import '../unit_repository.dart';

/// Converts a quantity from one unit of measure to another (`P2-01`).
///
/// A read-only use case: it loads the catalogue and delegates the arithmetic to
/// the pure [UnitConverter], so it records no audit entry.
final class ConvertQuantity {
  /// Creates the use case.
  const ConvertQuantity(this._repository);

  final UnitRepository _repository;

  /// Converts [amount] from [fromCode] to [toCode].
  ///
  /// Every unit is loaded, including disabled ones, so a historical document can
  /// still be recalculated. A conversion the catalogue cannot express comes back
  /// as a [ValidationFailure] naming the problem through its code.
  Future<Result<Quantity>> call({
    required Quantity amount,
    required String fromCode,
    required String toCode,
  }) async {
    final Result<List<Unit>> units = await _repository.readAll();
    return units.fold(
      ok: (List<Unit> catalogue) => UnitConverter.convert(
        amount: amount,
        fromCode: fromCode,
        toCode: toCode,
        catalogue: catalogue,
      ),
      err: Result<Quantity>.err,
    );
  }
}
