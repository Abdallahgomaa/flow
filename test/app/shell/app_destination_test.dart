import 'package:flow/app/shell/app_destination.dart';
import 'package:flow/shared/l10n/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every destination owns a unique, absolute path', () {
    final Set<String> paths = AppDestination.values
        .map((AppDestination destination) => destination.path)
        .toSet();

    expect(paths, hasLength(AppDestination.values.length));
    expect(paths.every((String path) => path.startsWith('/')), isTrue);
  });

  test('labels are localised in both languages', () async {
    final AppLocalizations en = await AppLocalizations.delegate.load(
      const Locale('en'),
    );
    final AppLocalizations ar = await AppLocalizations.delegate.load(
      const Locale('ar'),
    );

    for (final AppDestination destination in AppDestination.values) {
      expect(destination.label(en), isNotEmpty);
      expect(destination.label(ar), isNotEmpty);
      expect(destination.label(ar), isNot(destination.label(en)));
    }
  });
}
