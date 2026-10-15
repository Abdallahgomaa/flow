/// A unit of measure as stored in the `units` table (`P2-01`).
///
/// Pure Dart: the data layer maps a Drift row onto this entity. A unit is either
/// a *base* unit ([baseUnitCode] is `null`, worth exactly `1.000` of itself) or
/// is defined in terms of another unit: [factorThousandths] thousandths of the
/// unit it names. So `carton` with `baseUnitCode: 'piece'` and
/// `factorThousandths: 12000` means one carton is twelve pieces.
///
/// The factor is an integer number of thousandths rather than a `double`, so the
/// whole chain stays exact (AGENTS rule 2); [factor] exposes it as a [Quantity].
library;

import 'package:flow/core/money/money_core.dart';

/// An immutable unit record.
final class Unit {
  /// Creates a unit record.
  const Unit({
    required this.code,
    required this.name,
    required this.createdAt,
    this.baseUnitCode,
    this.factorThousandths,
    this.disabledAt,
    this.updatedAt,
  });

  /// Stable identifier and primary key: a slug such as `piece` or `carton`.
  final String code;

  /// Display name shown in pickers and on receipts.
  final String name;

  /// When the unit was created (UTC).
  final DateTime createdAt;

  /// The unit this one is measured in, or `null` when this is a base unit.
  final String? baseUnitCode;

  /// How many thousandths of [baseUnitCode] one of this unit is worth, or
  /// `null` when this is a base unit.
  final int? factorThousandths;

  /// When the unit was retired (UTC), or `null` while it is active.
  final DateTime? disabledAt;

  /// When the unit was last modified (UTC), or `null` if never.
  final DateTime? updatedAt;

  /// Whether this unit is its own reference point.
  bool get isBase => baseUnitCode == null;

  /// Whether the unit may no longer be assigned to a product.
  bool get isDisabled => disabledAt != null;

  /// [factorThousandths] as a [Quantity], or `null` for a base unit.
  Quantity? get factor => factorThousandths == null
      ? null
      : Quantity.thousandths(factorThousandths!);

  @override
  bool operator ==(Object other) =>
      other is Unit &&
      other.code == code &&
      other.name == name &&
      other.baseUnitCode == baseUnitCode &&
      other.factorThousandths == factorThousandths &&
      other.disabledAt == disabledAt &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
    code,
    name,
    baseUnitCode,
    factorThousandths,
    disabledAt,
    createdAt,
    updatedAt,
  );

  @override
  String toString() =>
      'Unit(code: $code, name: $name, baseUnitCode: $baseUnitCode, '
      'factorThousandths: $factorThousandths)';
}
