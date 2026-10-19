import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';

import '../unit.dart';
import '../unit_repository.dart';
import 'create_unit.dart';
import 'load_units.dart';

/// Makes sure the shop owns at least one unit of measure (`P2-06` follow-up).
///
/// A product cannot be stored without a stock unit: the column is a foreign key
/// onto `units.code`. Phase 2 ships no unit-management screen, so a brand-new
/// shop has no unit to pick and the product form can only answer "choose the
/// stock unit" — an error the operator has no way to fix. The first time the
/// form asks for its inputs, the catalogue therefore provisions one base unit.
///
/// It is idempotent: as soon as any unit exists nothing is written and no audit
/// entry is recorded, so calling it on every form open costs one read. The write
/// itself goes through [CreateUnit], which keeps the project rule that every
/// write is one audited unit of work (AGENTS rule 3) — nothing here reaches a
/// repository directly.
final class EnsureDefaultStockUnit {
  /// Creates the use case.
  const EnsureDefaultStockUnit(this._loadUnits, this._createUnit);

  final LoadUnits _loadUnits;
  final CreateUnit _createUnit;

  /// The base unit a fresh shop starts with: one piece.
  ///
  /// A base unit carries no conversion factor, so it is worth exactly `1.000`
  /// of itself and can be used for any countable article on its own.
  static const String code = 'piece';

  /// English display name for [code].
  ///
  /// Kept here rather than in `shared/l10n` for the same reason the built-in
  /// roles keep theirs: `domain` holds no presentation copy, and the name is
  /// stored data the operator can see and rename later, not a screen label.
  static const String defaultName = 'Piece';

  /// Provisions [code] when the catalogue holds no unit at all.
  ///
  /// Returns `ok(null)` when a unit already exists, when the catalogue is empty
  /// and the default unit was just created, or when a concurrent call created it
  /// first ("code taken" means the unit is there, which is all that was asked).
  /// A read that fails is propagated untouched: a storage problem must never be
  /// mistaken for a fresh installation, exactly as in `SeedBuiltInRoles`.
  Future<Result<void>> call() async {
    final Result<List<Unit>> existing = await _loadUnits();
    final List<Unit>? units = existing.valueOrNull;
    if (units == null) {
      return Result<void>.err(existing.failureOrNull!);
    }
    if (units.isNotEmpty) {
      return const Result<void>.ok(null);
    }

    final Result<Unit> created = await _createUnit(
      code: code,
      name: defaultName,
    );

    if (created case Err<Unit>(:final Failure failure)) {
      if (failure.code == UnitRepository.codeTakenCode) {
        return const Result<void>.ok(null);
      }
      return Result<void>.err(failure);
    }

    return const Result<void>.ok(null);
  }
}
