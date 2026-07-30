import '../database/database_provider.dart';
import '../models/set_list.dart';
import 'set_api.dart';
import 'set_local_store.dart';
import 'set_sync_preferences.dart';
import 'song_api.dart';
import 'song_local_store.dart';

class SetRepository {
  SetRepository({
    SetApi? api,
    SetLocalStore? localStore,
    SetSyncPreferences? syncPreferences,
    SongApi? songApi,
    SongLocalStore? songLocalStore,
  }) : _api = api ?? SetApi(),
       _localStore = localStore ?? SetLocalStore(DatabaseProvider.instance),
       _syncPreferences = syncPreferences ?? SetSyncPreferences(),
       _songApi = songApi ?? SongApi(),
       _songLocalStore =
           songLocalStore ?? SongLocalStore(DatabaseProvider.instance);

  final SetApi _api;
  final SetLocalStore _localStore;
  final SetSyncPreferences _syncPreferences;
  final SongApi _songApi;
  final SongLocalStore _songLocalStore;

  Future<List<SetList>> getLocalSets() {
    return _localStore.getAllSets();
  }

  Future<DateTime?> getLastSyncedAt() {
    return _syncPreferences.getLastSyncedAt();
  }

  /// Downloads sets along with the full content of every song they
  /// reference, replaces the local cache, and returns the synced sets.
  /// Caching each song's content locally lets set songs be opened offline.
  Future<List<SetList>> syncSets() async {
    final sets = await _api.fetchSets();

    final songIds = <int>{
      for (final set in sets)
        for (final setSong in set.setSongs) setSong.songId,
    };

    if (songIds.isNotEmpty) {
      final songs = await Future.wait(songIds.map(_songApi.fetchSong));
      await _songLocalStore.upsertSongs(songs);
    }

    await _localStore.replaceAll(sets);
    await _syncPreferences.setLastSyncedAt(DateTime.now().toUtc());
    return sets;
  }
}
