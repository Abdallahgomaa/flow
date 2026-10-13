enum AppFlavor {
  dev('Development'),
  prod('Production');

  const AppFlavor(this.label);

  final String label;

  static AppFlavor fromEnvironment() {
    const flavorName = String.fromEnvironment(
      'APP_FLAVOR',
      defaultValue: 'prod',
    );

    return switch (flavorName) {
      'dev' => AppFlavor.dev,
      _ => AppFlavor.prod,
    };
  }
}
