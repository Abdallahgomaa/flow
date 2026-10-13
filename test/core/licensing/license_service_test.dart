import 'package:cryptography/cryptography.dart';
import 'package:flow/core/licensing/licensing.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/clock.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory [LicenseStore] for tests.
final class _MemoryLicenseStore implements LicenseStore {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String rawKey) async => value = rawKey;

  @override
  Future<void> clear() async => value = null;
}

/// [DeviceIdProvider] returning a fixed raw id.
final class _FixedDeviceId implements DeviceIdProvider {
  _FixedDeviceId(this.raw);

  final String raw;

  @override
  Future<String> readRawDeviceId() async => raw;
}

void main() {
  const String product = 'flow-pos';
  final DateTime issuedAt = DateTime.utc(2026, 1, 1);
  final DateTime now = DateTime.utc(2026, 6, 1);

  late SimpleKeyPair signer;
  late SimplePublicKey publicKey;
  late String deviceHwid;

  License licenseFor({
    required String boundHwid,
    DateTime? expiresAt,
    String productId = product,
  }) => License(
    id: 'lic-0001',
    product: productId,
    hardwareId: boundHwid,
    issuedAt: issuedAt,
    expiresAt: expiresAt,
    features: const <String>{'pos'},
  );

  Future<String> signedKey(License license, {SimpleKeyPair? withKey}) async {
    final SimpleKeyPair keyPair = withKey ?? signer;
    final Signature signature = await Ed25519().sign(
      LicenseKey.signedBytes(license),
      keyPair: keyPair,
    );
    return LicenseKey.encode(license: license, signature: signature.bytes);
  }

  LicenseService service(LicenseStore store) => LicenseService(
    store: store,
    verifier: LicenseVerifier(publicKey: publicKey, product: product),
    hardwareId: HardwareId(provider: _FixedDeviceId('raw-device-1')),
    clock: FixedClock(now),
  );

  setUpAll(() async {
    signer = await Ed25519().newKeyPairFromSeed(List<int>.filled(32, 7));
    publicKey = (await signer.extract()).publicKey;
  });

  setUp(() async {
    deviceHwid = await HardwareId(provider: _FixedDeviceId('raw-device-1'))
        .compute();
  });

  test('activates a valid licence and persists it', () async {
    final _MemoryLicenseStore store = _MemoryLicenseStore();
    final License license = licenseFor(
      boundHwid: deviceHwid,
      expiresAt: DateTime.utc(2027, 1, 1),
    );
    final String raw = await signedKey(license);

    final Result<License> result = await service(store).activate(raw);

    expect(result.isOk, isTrue);
    expect(result.valueOrNull?.id, 'lic-0001');
    expect(store.value, raw);
  });

  test('rejects a licence bound to another device', () async {
    final String otherHwid = await HardwareId(
      provider: _FixedDeviceId('raw-device-2'),
    ).compute();
    final String raw = await signedKey(
      licenseFor(boundHwid: otherHwid, expiresAt: DateTime.utc(2027, 1, 1)),
    );

    final Result<License> result = await service(_MemoryLicenseStore())
        .activate(raw);

    expect(result.isErr, isTrue);
    expect(
      result.failureOrNull,
      isA<PermissionFailure>().having(
        (PermissionFailure failure) => failure.permission,
        'permission',
        'license.device',
      ),
    );
  });

  test('rejects an expired licence', () async {
    final String raw = await signedKey(
      licenseFor(boundHwid: deviceHwid, expiresAt: DateTime.utc(2026, 2, 1)),
    );

    final Result<License> result = await service(_MemoryLicenseStore())
        .activate(raw);

    expect(result.isErr, isTrue);
    expect(
      result.failureOrNull,
      isA<PermissionFailure>().having(
        (PermissionFailure failure) => failure.permission,
        'permission',
        'license.expired',
      ),
    );
  });

  test('rejects a licence signed by another key', () async {
    final SimpleKeyPair impostor = await Ed25519().newKeyPairFromSeed(
      List<int>.filled(32, 9),
    );
    final String raw = await signedKey(
      licenseFor(boundHwid: deviceHwid, expiresAt: DateTime.utc(2027, 1, 1)),
      withKey: impostor,
    );

    final Result<License> result = await service(_MemoryLicenseStore())
        .activate(raw);

    expect(result.isErr, isTrue);
    expect(result.failureOrNull, isA<CryptoFailure>());
  });

  test('rejects a licence for another product', () async {
    final String raw = await signedKey(
      licenseFor(
        boundHwid: deviceHwid,
        expiresAt: DateTime.utc(2027, 1, 1),
        productId: 'some-other-app',
      ),
    );

    final Result<License> result = await service(_MemoryLicenseStore())
        .activate(raw);

    expect(result.isErr, isTrue);
    expect(result.failureOrNull, isA<ValidationFailure>());
  });

  test('rejects a malformed key', () async {
    final Result<License> result = await service(_MemoryLicenseStore())
        .activate('not-a-key');

    expect(result.isErr, isTrue);
    expect(result.failureOrNull, isA<ValidationFailure>());
  });

  test('load reports a missing licence', () async {
    final Result<License> result = await service(_MemoryLicenseStore()).load();

    expect(result.isErr, isTrue);
    expect(result.failureOrNull, isA<NotFoundFailure>());
  });

  test('load re-validates a stored licence', () async {
    final _MemoryLicenseStore store = _MemoryLicenseStore();
    final LicenseService licenseService = service(store);
    await licenseService.activate(
      await signedKey(
        licenseFor(boundHwid: deviceHwid, expiresAt: DateTime.utc(2027, 1, 1)),
      ),
    );

    final Result<License> result = await licenseService.load();

    expect(result.isOk, isTrue);
    expect(result.valueOrNull?.product, product);
  });

  test('deactivate clears the stored licence', () async {
    final _MemoryLicenseStore store = _MemoryLicenseStore();
    final LicenseService licenseService = service(store);
    await licenseService.activate(
      await signedKey(
        licenseFor(boundHwid: deviceHwid, expiresAt: DateTime.utc(2027, 1, 1)),
      ),
    );

    await licenseService.deactivate();

    expect(store.value, isNull);
  });
}
