import 'package:flutter/foundation.dart';

import 'app_database.dart';

class DatabaseProvider {
  static AppDatabase? _instance;

  static AppDatabase get instance => _instance ??= AppDatabase();

  @visibleForTesting
  static set instance(AppDatabase database) {
    _instance = database;
  }

  @visibleForTesting
  static Future<void> reset() async {
    final existing = _instance;
    _instance = null;
    if (existing != null) {
      await existing.close();
    }
  }
}
