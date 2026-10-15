import 'package:flow/core/result/result.dart';

import 'unit.dart';

/// Reads and changes unit records (`P2-01`).
///
/// Every write here is one atomic, audited unit of work (AGENTS rule 3). Units
/// are never hard-deleted — [disable] retires them instead, so products and the
/// historical documents that mention them keep resolving their unit code.
abstract interface class UnitRepository {
  /// Failure code returned by [create] when the unit code already exists.
  static const String codeTakenCode = 'unit.codeTaken';

  /// Failure code returned by [create] when the named base unit does not exist.
  static const String baseNotFoundCode = 'unit.baseNotFound';

  /// Failure code returned by [create] when the new unit would close the chain of
  /// base units, for example making `piece` a child of `carton` while `carton` is
  /// already defined in terms of `piece`.
  static const String cycleCode = 'unit.cycle';

  /// Failure code returned by [readByCode] and [disable] when no row matches.
  static const String notFoundCode = 'unit.notFound';

  /// Every unit, including disabled ones, ordered by display name.
  Future<Result<List<Unit>>> readAll();

  /// The unit with [code], or a [NotFoundFailure] carrying [notFoundCode].
  Future<Result<Unit>> readByCode(String code);

  /// Inserts [unit] and appends one audit row for [action].
  ///
  /// [payload] is recorded verbatim in the audit entry and must stay free of
  /// personal data.
  Future<Result<Unit>> create({
    required Unit unit,
    required String action,
    Map<String, Object?> payload = const <String, Object?>{},
  });

  /// Logically disables the unit with [code] and appends an audit row.
  ///
  /// Disabling an already-disabled unit is a no-op and writes no audit entry,
  /// because nothing changed.
  Future<Result<void>> disable({
    required String code,
    required String action,
    Map<String, Object?> payload = const <String, Object?>{},
  });
}
