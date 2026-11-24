import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth_session.dart';

abstract class AuthTokenStore {
  Future<AuthSession?> read();

  Future<void> write(AuthSession session);

  Future<void> clear();
}

class SecureAuthTokenStore implements AuthTokenStore {
  SecureAuthTokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'auth_session';

  final FlutterSecureStorage _storage;

  @override
  Future<AuthSession?> read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    return AuthSession.fromJson(decoded);
  }

  @override
  Future<void> write(AuthSession session) {
    return _storage.write(key: _key, value: jsonEncode(session.toJson()));
  }

  @override
  Future<void> clear() {
    return _storage.delete(key: _key);
  }
}

class MemoryAuthTokenStore implements AuthTokenStore {
  AuthSession? session;

  @override
  Future<AuthSession?> read() async => session;

  @override
  Future<void> write(AuthSession session) async {
    this.session = session;
  }

  @override
  Future<void> clear() async {
    session = null;
  }
}
