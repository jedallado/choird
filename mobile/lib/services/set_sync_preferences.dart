import 'package:shared_preferences/shared_preferences.dart';

class SetSyncPreferences {
  static const _lastSyncedAtKey = 'sets_last_synced_at';

  Future<DateTime?> getLastSyncedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_lastSyncedAtKey);
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  Future<void> setLastSyncedAt(DateTime syncedAt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncedAtKey, syncedAt.toUtc().toIso8601String());
  }
}
