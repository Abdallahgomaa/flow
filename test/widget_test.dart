import 'package:flow/app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('theme mode controller starts on system', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeControllerProvider), ThemeMode.system);
  });

  test('cycle walks system -> light -> dark -> system', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    final ThemeModeController controller = container.read(
      themeModeControllerProvider.notifier,
    );

    controller.cycle();
    expect(container.read(themeModeControllerProvider), ThemeMode.light);

    controller.cycle();
    expect(container.read(themeModeControllerProvider), ThemeMode.dark);

    controller.cycle();
    expect(container.read(themeModeControllerProvider), ThemeMode.system);
  });

  test('setMode applies an explicit theme', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(themeModeControllerProvider.notifier)
        .setMode(ThemeMode.dark);
    expect(container.read(themeModeControllerProvider), ThemeMode.dark);
  });
}
