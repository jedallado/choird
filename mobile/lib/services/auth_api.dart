import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/auth_session.dart';

class AuthException implements Exception {
  AuthException(this.message, {this.unauthorized = false});

  final String message;
  final bool unauthorized;

  @override
  String toString() => message;
}

class AuthApi {
  AuthApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse(ApiConfig.loginUrl),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email.trim(), 'password': password}),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> ||
          decoded['token'] is! String ||
          decoded['user'] is! Map<String, dynamic>) {
        throw AuthException('Unexpected response format from the server.');
      }

      return AuthSession.fromJson(decoded);
    }

    throw AuthException(_message(response) ?? 'Could not sign in.');
  }

  Future<void> changePassword({
    required String token,
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _client.put(
      Uri.parse(ApiConfig.userUrl),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'password': password,
        'passwordConfirmation': passwordConfirmation,
      }),
    );

    if (response.statusCode == 200) {
      return;
    }

    throw AuthException(
      _message(response) ?? 'Could not change your password.',
      unauthorized: response.statusCode == 401,
    );
  }

  Future<void> logout(String token) async {
    final response = await _client.post(
      Uri.parse(ApiConfig.logoutUrl),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw AuthException('Could not sign out.');
    }
  }

  String? _message(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final message = decoded['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }

      final errors = decoded['errors'];
      if (errors is Map) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty && value.first is String) {
            return value.first as String;
          }
        }
      }
    } catch (_) {
      return null;
    }

    return null;
  }
}
