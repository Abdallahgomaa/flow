import 'money.dart';
import 'rate.dart';
import 'rounding_mode.dart';
import 'tax_mode.dart';

/// The full tax breakdown for a single line or basket.
final class TaxResult {
  const TaxResult({
    required this.net,
    required this.tax,
    required this.gross,
    required this.perRate,
  });

  /// The amount before tax.
  final Money net;

  /// The total tax charged.
  final Money tax;

  /// The amount after tax.
  final Money gross;

  /// The tax contributed by each rate, in the same order the rates were given.
  ///
  /// The elements always sum to exactly [tax].
  final List<Money> perRate;

  @override
  String toString() =>
      'TaxResult(net: $net, tax: $tax, gross: $gross, perRate: $perRate)';
}

/// Computes tax for a line or basket while preserving exact integer sums.
///
/// The invariant `net + tax == gross` always holds, and the per-rate amounts
/// always sum to `tax` (largest-remainder distribution handles rounding).
abstract final class TaxCalculator {
  const TaxCalculator._();

  /// Calculates tax for [amount] under [mode].
  ///
  /// * [TaxMode.exclusive]: [amount] is net; tax is added on top.
  /// * [TaxMode.inclusive]: [amount] is gross; tax is extracted from it.
  ///
  /// A zero or empty [rates] list yields zero tax.
  static TaxResult calculate({
    required Money amount,
    required TaxMode mode,
    required List<Rate> rates,
    RoundingMode rounding = RoundingMode.halfUp,
  }) {
    return switch (mode) {
      TaxMode.exclusive => _exclusive(amount, rates, rounding),
      TaxMode.inclusive => _inclusive(amount, rates, rounding),
    };
  }

  static TaxResult _exclusive(
    Money amount,
    List<Rate> rates,
    RoundingMode rounding,
  ) {
    final Money net = amount;
    final List<Money> perRate = <Money>[
      for (final Rate rate in rates) net.applyRate(rate, mode: rounding),
    ];
    Money tax = Money.zero(amount.currency);
    for (final Money part in perRate) {
      tax = tax + part;
    }
    return TaxResult(net: net, tax: tax, gross: net + tax, perRate: perRate);
  }

  static TaxResult _inclusive(
    Money amount,
    List<Rate> rates,
    RoundingMode rounding,
  ) {
    final Money gross = amount;
    final List<int> ratios = <int>[
      for (final Rate rate in rates) rate.basisPoints,
    ];
    int totalBasisPoints = 0;
    for (final int ratio in ratios) {
      totalBasisPoints += ratio;
    }
    if (totalBasisPoints == 0) {
      return TaxResult(
        net: gross,
        tax: Money.zero(gross.currency),
        gross: gross,
        perRate: <Money>[
          for (int i = 0; i < rates.length; i++) Money.zero(gross.currency),
        ],
      );
    }
    final Money tax = gross.multiplyRatio(
      totalBasisPoints,
      10000 + totalBasisPoints,
      mode: rounding,
    );
    final Money net = gross - tax;
    return TaxResult(
      net: net,
      tax: tax,
      gross: gross,
      perRate: tax.allocate(ratios),
    );
  }
}
