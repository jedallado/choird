import 'package:choird/models/auth_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const user = AuthUser(
    id: 1,
    name: 'Ada',
    email: 'ada@example.com',
    role: 'member',
  );

  test('a session is expired at its expiry time', () {
    final expiresAt = DateTime.utc(2026, 11, 30, 3);
    final session = AuthSession(
      token: 'token-1',
      expiresAt: expiresAt,
      user: user,
    );

    expect(
      session.isExpired(expiresAt.subtract(const Duration(days: 1))),
      isFalse,
    );
    expect(session.isExpired(expiresAt), isTrue);
  });
}
