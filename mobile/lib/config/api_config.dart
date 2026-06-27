import 'dart:io';

import 'package:flutter/foundation.dart';

import 'api_config.local.dart';

class ApiConfig {
  static const String _productionBaseUrl =
      'https://choird-production.up.railway.app';

  static String get baseUrl {
    if (kReleaseMode) {
      return _productionBaseUrl;
    }

    if (localApiBaseUrl != null && localApiBaseUrl!.isNotEmpty) {
      return localApiBaseUrl!;
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    }

    return 'http://127.0.0.1:8000';
  }

  static String get songsUrl => '$baseUrl/api/songs';
}
