/// Checks that match PUT /api/user password rules.
///
/// The new password is required, at least 8 characters, and must match its
/// confirmation. The current password is required. The server is the only
/// place that can tell whether that current password is correct.
abstract final class PasswordChangeRules {
  static const minLength = 8;

  static String? currentPasswordError(String? value) {
    if (value == null || value.isEmpty) {
      return 'Current password is required to change your password.';
    }

    return null;
  }

  static String? newPasswordError(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }

    if (value.length < minLength) {
      return 'Password must be at least 8 characters.';
    }

    return null;
  }

  static String? confirmationError({
    required String password,
    required String confirmation,
  }) {
    if (confirmation != password) {
      return 'Password confirmation does not match.';
    }

    return null;
  }
}
