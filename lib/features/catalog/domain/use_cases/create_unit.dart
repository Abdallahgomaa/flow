import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/clock.dart';

import '../unit.dart';
import '../unit_repository.dart';

/// Validates and creates a unit of measure.
///
/// This is the only way a unit is ever written (AGENTS rule 3): callers use the
/// use case, and the repository wraps the row plus its audit entry in one unit
/// of work. The unit code is its own primary key, so only `createdAt` has to be
/// decided here, from the same [Clock] the row is stamped with.
final class CreateUnit {
  /// Creates the use case.
  const CreateUnit(this._repository, this._clock);

  final UnitRepository _repository;
  final Clock _clock;

  /// Audit action recorded for every created unit.
  static const String auditAction = 'unit.created';

  /// Failure code used when the unit code is missing.
  static const String codeRequiredCode = 'unit.codeRequired';

  /// Failure code used when the unit code is not a well-formed slug.
  static const String codeInvalidCode = 'unit.codeInvalid';

  /// Failure code used when the unit name is missing.
  static const String nameRequiredCode = 'unit.nameRequired';

  /// Failure code used when a non-base unit carries no factor.
  static const String factorRequiredCode = 'unit.factorRequired';

  /// Failure code used when a factor is zero or negative.
  static const String factorInvalidCode = 'unit.factorInvalid';

  /// The shape a unit code must have: lowercase letters and digits separated by
  /// single dots, dashes or underscores — for example `piece`, `carton` or `kg`.
  /// The code is stored on every product and every document line, so it has to
  /// stay machine-friendly.
  static final RegExp _codePattern = RegExp(r'^[a-z0-9]+([._-][a-z0-9]+)*$');

  /// Validates the fields and creates the unit.
  ///
  /// A unit without [baseUnitCode] is a base unit: it must not carry a factor,
  /// because it is worth exactly `1.000` of itself. Any other unit names an
  /// existing unit plus how many thousandths of it one unit holds, for example
  /// `carton` = `12000` thousandths of `piece`.
  ///
  /// Returns the stored unit on success, or a [ValidationFailure] naming the
  /// first problem via its code. A base unit that does not exist comes back as a
  /// [NotFoundFailure], and a chain that would close a loop as a
  /// [ConflictFailure], both from the repository.
  Future<Result<Unit>> call({
    required String code,
    required String name,
    String? baseUnitCode,
    int? factorThousandths,
  }) async {
    final String trimmedCode = code.trim().toLowerCase();
    if (trimmedCode.isEmpty) {
      return const Result<Unit>.err(
        ValidationFailure(
          message: 'Enter a unit code.',
          code: codeRequiredCode,
        ),
      );
    }
    if (!_codePattern.hasMatch(trimmedCode)) {
      return const Result<Unit>.err(
        ValidationFailure(
          message:
              'Use lowercase letters, digits, dots, dashes or underscores.',
          code: codeInvalidCode,
        ),
      );
    }

    final String trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return const Result<Unit>.err(
        ValidationFailure(
          message: 'Enter a unit name.',
          code: nameRequiredCode,
        ),
      );
    }

    final String? base = _normalise(baseUnitCode)?.toLowerCase();
    if (base == null) {
      return _repository.create(
        unit: Unit(
          code: trimmedCode,
          name: trimmedName,
          createdAt: _clock.nowUtc(),
        ),
        action: auditAction,
        payload: <String, Object?>{'code': trimmedCode},
      );
    }

    if (factorThousandths == null) {
      return const Result<Unit>.err(
        ValidationFailure(
          message: 'Enter how much of the base unit this unit holds.',
          code: factorRequiredCode,
        ),
      );
    }
    if (factorThousandths <= 0) {
      return const Result<Unit>.err(
        ValidationFailure(
          message: 'The conversion factor must be greater than zero.',
          code: factorInvalidCode,
        ),
      );
    }

    return _repository.create(
      unit: Unit(
        code: trimmedCode,
        name: trimmedName,
        createdAt: _clock.nowUtc(),
        baseUnitCode: base,
        factorThousandths: factorThousandths,
      ),
      action: auditAction,
      payload: <String, Object?>{
        'code': trimmedCode,
        'baseUnitCode': base,
        'factorThousandths': factorThousandths,
      },
    );
  }

  /// Trims [value] and maps blank input to `null`, so an empty code is stored as
  /// "no base" rather than as an empty string.
  static String? _normalise(String? value) {
    final String? trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}
