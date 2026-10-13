import 'package:flow/features/auth/domain/permission.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every permission has a dotted, lowercase code', () {
    final RegExp pattern = RegExp(r'^[a-z]+(\.[a-z]+)+$');
    for (final Permission permission in Permission.values) {
      expect(
        pattern.hasMatch(permission.code),
        isTrue,
        reason: '${permission.name} has an invalid code: ${permission.code}',
      );
    }
  });

  test('codes are unique', () {
    final Set<String> codes = <String>{
      for (final Permission permission in Permission.values) permission.code,
    };
    expect(codes, hasLength(Permission.values.length));
  });

  test('fromCode resolves every permission', () {
    for (final Permission permission in Permission.values) {
      expect(Permission.fromCode(permission.code), same(permission));
    }
  });

  test('fromCode degrades to null for unknown input', () {
    expect(Permission.fromCode(null), isNull);
    expect(Permission.fromCode(''), isNull);
    expect(Permission.fromCode('nope.nope'), isNull);
    // Codes are case-sensitive machine identifiers.
    expect(Permission.fromCode('SALE.CREATE'), isNull);
  });
}
