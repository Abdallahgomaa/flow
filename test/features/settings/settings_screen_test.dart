import 'package:drift/drift.dart' show QueryExecutor;
import 'package:drift/native.dart';
import 'package:flow/core/database/database.dart';
import 'package:flow/core/database/database_providers.dart';
import 'package:flow/core/money/rate.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/features/settings/data/settings_providers.dart';
import 'package:flow/features/settings/domain/business_profile.dart';
import 'package:flow/features/settings/presentation/settings_screen.dart';
import 'package:flow/shared/l10n/l10n.dart';
import 'package:flow/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory [DatabaseConnector] so the screen runs against a real Drift
/// database without SQLCipher or the file system.
final class _MemoryConnector implements DatabaseConnector {
  @override
  QueryExecutor open() => NativeDatabase.memory(setup: DatabasePragmas.apply);
}

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        databaseConnectorProvider.overrideWith((Ref ref) => _MemoryConnector()),
      ],
    );
    addTearDown(container.dispose);
  });

  /// The text field that carries the given [label] in its decoration.
  Finder fieldWithLabel(String label) => find.descendant(
    of: find.ancestor(
      of: find.text(label),
      matching: find.byType(CustomTextField),
    ),
    matching: find.byType(TextFormField),
  );

  Future<void> pumpSettings(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: kSupportedLocales,
          home: Scaffold(
            body: SettingsScreen(
              themeMode: ThemeMode.system,
              languageCode: null,
              onThemeModeChanged: (ThemeMode mode) {},
              onLanguageChanged: (String? code) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a fresh install opens the form with the defaults', (
    WidgetTester tester,
  ) async {
    await pumpSettings(tester);

    expect(find.text('Business profile'), findsOneWidget);
    expect(find.text('Business name'), findsOneWidget);
    expect(fieldWithLabel('Business name'), findsOneWidget);
  });

  testWidgets('saving writes the profile to the database and audits it', (
    WidgetTester tester,
  ) async {
    await pumpSettings(tester);

    await tester.enterText(fieldWithLabel('Business name'), 'Flow Market');
    await tester.enterText(fieldWithLabel('Tax rate'), '14');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // The use case really persisted it…
    final Result<BusinessProfile> stored = await container.read(
      loadBusinessProfileProvider,
    )();
    expect(stored.valueOrNull?.name, 'Flow Market');
    expect(stored.valueOrNull?.taxRate, const Rate.basisPoints(1400));

    // …the write was audited, and the chain still verifies…
    final AppDatabase database = container.read(appDatabaseProvider);
    final List<AuditLogData> entries = await database
        .select(database.auditLog)
        .get();
    expect(entries, hasLength(1));
    expect(entries.single.entity, 'app_settings');
    expect(
      (await container.read(auditServiceProvider).verifyChain()).isIntact,
      isTrue,
    );

    // …and the user was told.
    expect(find.text('Saved'), findsOneWidget);
  });

  testWidgets('reopening the screen loads the stored values back', (
    WidgetTester tester,
  ) async {
    await container.read(saveBusinessProfileProvider)(
      const BusinessProfile(
        name: 'Cairo Grocer',
        currencyCode: 'EGP',
        taxRate: Rate.basisPoints(1400),
      ),
    );

    await pumpSettings(tester);

    expect(find.text('Cairo Grocer'), findsOneWidget);
    expect(find.text('14'), findsOneWidget);
  });

  testWidgets('a blank name is refused and never persisted', (
    WidgetTester tester,
  ) async {
    await pumpSettings(tester);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a business name.'), findsOneWidget);

    final Result<BusinessProfile> stored = await container.read(
      loadBusinessProfileProvider,
    )();
    expect(stored.valueOrNull?.name, isEmpty);
    expect(await _auditCount(container), 0);
  });
}

/// Number of audit rows written so far.
Future<int> _auditCount(ProviderContainer container) async {
  final AppDatabase database = container.read(appDatabaseProvider);
  final List<AuditLogData> entries = await database
      .select(database.auditLog)
      .get();
  return entries.length;
}
