import 'package:flow/features/auth/domain/user_role.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the four built-in roles ship with their codes', () {
    expect(UserRole.values, hasLength(4));
    expect(UserRole.values.map((UserRole role) => role.code), <String>[
      'owner',
      'cashier',
      'inventory',
      'accountant',
    ]);
  });

  test('fromCode resolves every role', () {
    for (final UserRole role in UserRole.values) {
      expect(UserRole.fromCode(role.code), same(role));
    }
  });

  test('fromCode degrades to null for unknown input', () {
    expect(UserRole.fromCode(null), isNull);
    expect(UserRole.fromCode(''), isNull);
    expect(UserRole.fromCode('manager'), isNull);
    expect(UserRole.fromCode('OWNER'), isNull);
  });
}
