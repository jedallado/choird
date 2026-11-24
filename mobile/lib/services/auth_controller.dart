import 'package:flutter/foundation.dart';

import '../models/auth_session.dart';
import 'auth_api.dart';
import 'auth_token_store.dart';

class AuthController extends ChangeNotifier {
  AuthController({AuthApi? api, AuthTokenStore? store})
    : _api = api ?? AuthApi(),
      _store = store ?? SecureAuthTokenStore();

  static AuthController? instance;

  final AuthApi _api;
  final AuthTokenStore _store;

  AuthSession? session;
  bool isReady = false;

  Future<void> load() async {
    final stored = await _store.read();
    if (stored == null || stored.isExpired()) {
      if (stored != null) {
        await _store.clear();
      }
      session = null;
    } else {
      session = stored;
    }

    isReady = true;
    notifyListeners();
  }

  Future<void> signIn({required String email, required String password}) async {
    final next = await _api.login(email: email, password: password);
    await _store.write(next);
    session = next;
    notifyListeners();
  }

  Future<void> signOut() async {
    final token = session?.token;
    session = null;
    await _store.clear();
    notifyListeners();

    if (token == null) {
      return;
    }

    try {
      await _api.logout(token);
    } catch (_) {
      // The phone is signed out either way. The token expires on its own.
    }
  }

  Future<void> handleUnauthorized() async {
    if (session == null) {
      return;
    }

    session = null;
    await _store.clear();
    notifyListeners();
  }

  Future<void> expireIfNeeded() async {
    final current = session;
    if (current == null || !current.isExpired()) {
      return;
    }

    await handleUnauthorized();
  }
}
