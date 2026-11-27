import 'package:choird/models/password_change_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('current password is required and has no minimum length', () {
    expect(
      PasswordChangeRules.currentPasswordError(''),
      'Current password is required to change your password.',
    );
    expect(PasswordChangeRules.currentPasswordError('secret'), isNull);
  });

  test('new password is required and must be at least 8 characters', () {
    expect(PasswordChangeRules.newPasswordError(''), 'Password is required.');
    expect(
      PasswordChangeRules.newPasswordError('short'),
      'Password must be at least 8 characters.',
    );
    expect(PasswordChangeRules.newPasswordError('password'), isNull);
  });

  test('confirmation must match the new password exactly', () {
    expect(
      PasswordChangeRules.confirmationError(
        password: 'new-password',
        confirmation: 'other-password',
      ),
      'Password confirmation does not match.',
    );
    expect(
      PasswordChangeRules.confirmationError(
        password: 'new-password',
        confirmation: 'new-password',
      ),
      isNull,
    );
    expect(
      PasswordChangeRules.confirmationError(password: '', confirmation: ''),
      isNull,
    );
  });
}
