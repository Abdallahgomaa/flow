// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The low-level engine that backs [appDatabaseProvider].
///
/// There is no safe default (the app must pick SQLCipher and the file
/// location), so `bootstrap` overrides it — the same pattern as
/// `appFlavorProvider`. Tests override it with an in-memory connector.

@ProviderFor(databaseConnector)
final databaseConnectorProvider = DatabaseConnectorProvider._();

/// The low-level engine that backs [appDatabaseProvider].
///
/// There is no safe default (the app must pick SQLCipher and the file
/// location), so `bootstrap` overrides it — the same pattern as
/// `appFlavorProvider`. Tests override it with an in-memory connector.

final class DatabaseConnectorProvider
    extends
        $FunctionalProvider<
          DatabaseConnector,
          DatabaseConnector,
          DatabaseConnector
        >
    with $Provider<DatabaseConnector> {
  /// The low-level engine that backs [appDatabaseProvider].
  ///
  /// There is no safe default (the app must pick SQLCipher and the file
  /// location), so `bootstrap` overrides it — the same pattern as
  /// `appFlavorProvider`. Tests override it with an in-memory connector.
  DatabaseConnectorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'databaseConnectorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$databaseConnectorHash();

  @$internal
  @override
  $ProviderElement<DatabaseConnector> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DatabaseConnector create(Ref ref) {
    return databaseConnector(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DatabaseConnector value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DatabaseConnector>(value),
    );
  }
}

String _$databaseConnectorHash() => r'9093ee1b5377665f5ba9b8853bc5a7a5b7bd0805';

/// The application database, opened on first use and closed on dispose.
///
/// Everything that persists lives behind this provider, so there is exactly
/// one connection for the whole process.

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

/// The application database, opened on first use and closed on dispose.
///
/// Everything that persists lives behind this provider, so there is exactly
/// one connection for the whole process.

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  /// The application database, opened on first use and closed on dispose.
  ///
  /// Everything that persists lives behind this provider, so there is exactly
  /// one connection for the whole process.
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'464cea0fbb5ab48b9d4bbe3914e9300054a36746';

/// Groups writes into atomic units of work (AGENTS rule 3).

@ProviderFor(unitOfWork)
final unitOfWorkProvider = UnitOfWorkProvider._();

/// Groups writes into atomic units of work (AGENTS rule 3).

final class UnitOfWorkProvider
    extends $FunctionalProvider<UnitOfWork, UnitOfWork, UnitOfWork>
    with $Provider<UnitOfWork> {
  /// Groups writes into atomic units of work (AGENTS rule 3).
  UnitOfWorkProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unitOfWorkProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unitOfWorkHash();

  @$internal
  @override
  $ProviderElement<UnitOfWork> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UnitOfWork create(Ref ref) {
    return unitOfWork(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UnitOfWork value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UnitOfWork>(value),
    );
  }
}

String _$unitOfWorkHash() => r'71707f22cc1e33d9c9360b20a2ad0c64fb79ffcc';

/// Appends to the append-only audit chain of [appDatabaseProvider].

@ProviderFor(auditService)
final auditServiceProvider = AuditServiceProvider._();

/// Appends to the append-only audit chain of [appDatabaseProvider].

final class AuditServiceProvider
    extends $FunctionalProvider<AuditService, AuditService, AuditService>
    with $Provider<AuditService> {
  /// Appends to the append-only audit chain of [appDatabaseProvider].
  AuditServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'auditServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$auditServiceHash();

  @$internal
  @override
  $ProviderElement<AuditService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuditService create(Ref ref) {
    return auditService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuditService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuditService>(value),
    );
  }
}

String _$auditServiceHash() => r'8c95ad0623f990e089d8cdd8c5d5024926bc4942';
