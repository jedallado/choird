import 'package:http/http.dart' as http;

import 'auth_controller.dart';

Future<Map<String, String>> apiHeaders() async {
  final token = AuthController.instance?.session?.token;
  return {
    'Accept': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };
}

Future<bool> sessionWasRejected(http.Response response) async {
  if (response.statusCode != 401) {
    return false;
  }

  await AuthController.instance?.handleUnauthorized();
  return true;
}
