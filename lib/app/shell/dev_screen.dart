import 'package:flutter/material.dart';

import '../../core/money/money_core.dart';
import '../../shared/design/app_dimens.dart';
import '../../shared/l10n/l10n.dart';
import '../../shared/widgets/widgets.dart';

/// Developer-only Money/Tax playground.
///
/// Lives outside the adaptive shell and owns its own `Scaffold` (it is a
/// pushed, full-screen route). It is a manual calculator built purely on the
/// `core/money` package — it performs no I/O and writes nothing.
class DevScreen extends StatefulWidget {
  const DevScreen({super.key});

  @override
  State<DevScreen> createState() => _DevScreenState();
}

class _DevScreenState extends State<DevScreen> {
  final TextEditingController _amountController = TextEditingController(
    text: '100.00',
  );
  final TextEditingController _rateController = TextEditingController(
    text: '14',
  );
  final TextEditingController _quantityController = TextEditingController(
    text: '3',
  );

  Currency _currency = Currency.egp;
  TaxMode _mode = TaxMode.exclusive;

  @override
  void dispose() {
    _amountController.dispose();
    _rateController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  /// Runs the pure money/tax pipeline for the current inputs.
  ///
  /// Returns `null` when any field is not a valid value, so the UI can show
  /// `devInvalidAmount` instead of throwing.
  _PlaygroundResult? _compute() {
    final Money? amount = Money.parse(
      _amountController.text,
      _currency,
    ).valueOrNull;
    final Rate? rate = Rate.parsePercent(_rateController.text).valueOrNull;
    final Quantity? quantity = Quantity.parse(_quantityController.text)
        .valueOrNull;
    if (amount == null || rate == null || quantity == null) {
      return null;
    }

    final TaxResult tax = TaxCalculator.calculate(
      amount: amount,
      mode: _mode,
      rates: <Rate>[rate],
    );
    return _PlaygroundResult(
      tax: tax,
      lineTotal: quantity.lineTotal(tax.gross),
      formatter: const MoneyFormatter(),
    );
  }

  void _recompute(String _) => setState(() {});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final _PlaygroundResult? result = _compute();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.devScreenTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            Text(
              l10n.devScreenSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _FieldLabel(text: l10n.devCurrencyLabel),
            DropdownButton<Currency>(
              value: _currency,
              isExpanded: true,
              items: <DropdownMenuItem<Currency>>[
                for (final Currency currency in Currency.predefined)
                  DropdownMenuItem<Currency>(
                    value: currency,
                    child: Text(currency.code),
                  ),
              ],
              onChanged: (Currency? value) {
                if (value != null) {
                  setState(() => _currency = value);
                }
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            _FieldLabel(text: l10n.devTaxModeLabel),
            SegmentedButton<TaxMode>(
              segments: <ButtonSegment<TaxMode>>[
                ButtonSegment<TaxMode>(
                  value: TaxMode.exclusive,
                  label: Text(l10n.devTaxExclusive),
                ),
                ButtonSegment<TaxMode>(
                  value: TaxMode.inclusive,
                  label: Text(l10n.devTaxInclusive),
                ),
              ],
              selected: <TaxMode>{_mode},
              onSelectionChanged: (Set<TaxMode> selection) =>
                  setState(() => _mode = selection.first),
            ),
            const SizedBox(height: AppSpacing.lg),
            CustomTextField(
              controller: _amountController,
              label: l10n.devAmountLabel,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: _recompute,
            ),
            const SizedBox(height: AppSpacing.md),
            CustomTextField(
              controller: _rateController,
              label: l10n.devTaxRateLabel,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: _recompute,
            ),
            const SizedBox(height: AppSpacing.md),
            CustomTextField(
              controller: _quantityController,
              label: l10n.devQuantityLabel,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: _recompute,
            ),
            const SizedBox(height: AppSpacing.xl),
            if (result == null)
              Text(
                l10n.devInvalidAmount,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              )
            else
              CustomCard(
                child: Column(
                  children: <Widget>[
                    _ResultRow(
                      label: l10n.devNetLabel,
                      value: result.formatter.format(result.tax.net),
                    ),
                    _ResultRow(
                      label: l10n.devTaxLabel,
                      value: result.formatter.format(result.tax.tax),
                    ),
                    _ResultRow(
                      label: l10n.devGrossLabel,
                      value: result.formatter.format(result.tax.gross),
                    ),
                    _ResultRow(
                      label: l10n.devLineTotalLabel,
                      value: result.formatter.format(result.lineTotal),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Immutable snapshot of the playground computation.
class _PlaygroundResult {
  const _PlaygroundResult({
    required this.tax,
    required this.lineTotal,
    required this.formatter,
  });

  final TaxResult tax;
  final Money lineTotal;
  final MoneyFormatter formatter;
}

/// Small bold caption that introduces a control.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
    child: Text(text, style: Theme.of(context).textTheme.labelLarge),
  );
}

/// Label/value line inside the results card.
class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: <Widget>[
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
