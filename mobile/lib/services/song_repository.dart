import '../database/database_provider.dart';
import '../models/song.dart';
import 'song_api.dart';
import 'song_local_store.dart';
import 'song_sync_preferences.dart';

class SongRepository {
  SongRepository({
    SongApi? api,
    SongLocalStore? localStore,
    SongSyncPreferences? syncPreferences,
  }) : _api = api ?? SongApi(),
       _localStore = localStore ?? SongLocalStore(DatabaseProvider.instance),
       _syncPreferences = syncPreferences ?? SongSyncPreferences();

  final SongApi _api;
  final SongLocalStore _localStore;
  final SongSyncPreferences _syncPreferences;

  Future<List<Song>> getLocalSongs() {
    return _localStore.getAllSongs();
  }

  Future<DateTime?> getLastSyncedAt() {
    return _syncPreferences.getLastSyncedAt();
  }

  /// Downloads the full catalog, replaces the local cache, and returns it.
  Future<List<Song>> syncSongs() async {
    final songs = await _api.fetchSongs();
    await _localStore.replaceAll(songs);
    await _syncPreferences.setLastSyncedAt(DateTime.now().toUtc());
    return songs;
  }
}
