import 'package:flow/core/licensing/license.dart';
import 'package:flow/core/licensing/license_key.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final String boundHwid = List<String>.filled(64, 'a').join();

  License licenseAt({DateTime? expiresAt}) => License(
    id: 'lic-0001',
    product: 'flow-pos',
    hardwareId: boundHwid,
    issuedAt: DateTime.utc(2026, 1, 1),
    expiresAt: expiresAt,
    features: const <String>{'inventory', 'pos'},
  );

  group('License', () {
    test('round-trips through its payload', () {
      final License original = licenseAt(expiresAt: DateTime.utc(2027, 1, 1));
      final License restored = License.fromPayload(
        original.toPayload().cast<String, dynamic>(),
      );

      expect(restored.id, original.id);
      expect(restored.product, original.product);
      expect(restored.hardwareId, original.hardwareId);
      expect(restored.issuedAt, original.issuedAt);
      expect(restored.expiresAt, original.expiresAt);
      expect(restored.features, original.features);
    });

    test('supports perpetual licences', () {
      final License perpetual = licenseAt();

      expect(perpetual.isPerpetual, isTrue);
      expect(perpetual.isExpiredAt(DateTime.utc(3000)), isFalse);
    });

    test('reports expiry against a UTC instant', () {
      final License expiring = licenseAt(expiresAt: DateTime.utc(2027, 1, 1));

      expect(expiring.isPerpetual, isFalse);
      expect(expiring.isExpiredAt(DateTime.utc(2026, 12, 31)), isFalse);
      expect(expiring.isExpiredAt(DateTime.utc(2027, 1, 1)), isTrue);
      expect(expiring.isExpiredAt(DateTime.utc(2027, 6, 1)), isTrue);
    });
  });

  group('LicenseKey', () {
    test('encodes and decodes a key with its signature', () {
      final License license = licenseAt(expiresAt: DateTime.utc(2027, 1, 1));
      final List<int> signature = List<int>.generate(64, (int index) => index);

      final String raw = LicenseKey.encode(
        license: license,
        signature: signature,
      );
      final ParsedLicenseKey? parsed = LicenseKey.tryDecode(raw);

      expect(raw.startsWith('FLOW1.'), isTrue);
      expect(parsed, isNotNull);
      expect(parsed!.license.id, license.id);
      expect(parsed.signature, signature);
      expect(parsed.signedPayload, LicenseKey.signedBytes(license));
    });

    test('is deterministic for the same licence', () {
      final License license = licenseAt(expiresAt: DateTime.utc(2027, 1, 1));

      expect(
        LicenseKey.encode(license: license, signature: const <int>[1, 2, 3]),
        LicenseKey.encode(license: license, signature: const <int>[1, 2, 3]),
      );
    });

    test('returns null for malformed keys', () {
      expect(LicenseKey.tryDecode(''), isNull);
      expect(LicenseKey.tryDecode('nope'), isNull);
      expect(LicenseKey.tryDecode('FLOW1.only-two'), isNull);
      expect(LicenseKey.tryDecode('FLOW1.bm90anNvbg.AA'), isNull);
      expect(LicenseKey.tryDecode('FLOW1.bm90anNvbg.bm90.YQ'), isNull);
      expect(LicenseKey.tryDecode('FLOW2.eyJhIjoxfQ.AA'), isNull);
    });
  });
}
