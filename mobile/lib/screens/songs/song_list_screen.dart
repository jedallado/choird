import 'package:flutter/material.dart';

import '../../models/song.dart';
import '../../services/song_repository.dart';
import 'song_detail_screen.dart';

class SongListScreen extends StatefulWidget {
  const SongListScreen({super.key, SongRepository? repository})
    : _repository = repository;

  final SongRepository? _repository;

  @override
  State<SongListScreen> createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen> {
  late final SongRepository _repository =
      widget._repository ?? SongRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Song> _songs = [];
  DateTime? _lastSyncedAt;
  String _searchQuery = '';
  bool _isLoading = true;
  bool _isSyncing = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadLocalSongs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLocalSongs() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final songs = await _repository.getLocalSongs();
      final lastSyncedAt = await _repository.getLastSyncedAt();
      if (!mounted) {
        return;
      }

      setState(() {
        _songs = songs;
        _lastSyncedAt = lastSyncedAt;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadError = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _syncSongs() async {
    if (_isSyncing) {
      return;
    }

    setState(() {
      _isSyncing = true;
    });

    try {
      final songs = await _repository.syncSongs();
      final lastSyncedAt = await _repository.getLastSyncedAt();
      if (!mounted) {
        return;
      }

      setState(() {
        _songs = songs;
        _lastSyncedAt = lastSyncedAt;
        _loadError = null;
        _isSyncing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Songs synced.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSyncing = false;
      });

      final message = error.toString();
      if (_songs.isEmpty) {
        setState(() {
          _loadError = message;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not sync songs. $message')),
        );
      }
    }
  }

  List<Song> _filterSongs(List<Song> songs) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return songs;
    }

    return songs.where((song) {
      final titleMatches = song.title.toLowerCase().contains(query);
      final artistMatches =
          song.artist?.toLowerCase().contains(query) ?? false;
      return titleMatches || artistMatches;
    }).toList();
  }

  void _openSongDetail(Song song) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SongDetailScreen(song: song),
      ),
    );
  }

  String _formatLastSyncedAt(DateTime syncedAt) {
    final local = syncedAt.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null && _songs.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.6,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 16),
                    Text(_loadError!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _isSyncing ? null : _syncSongs,
                      child: Text(_isSyncing ? 'Syncing…' : 'Sync songs'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (_songs.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.6,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_download_outlined, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Connect once to download songs for offline use.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _isSyncing ? null : _syncSongs,
                      child: Text(_isSyncing ? 'Syncing…' : 'Sync songs'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    final songs = _filterSongs(_songs);

    if (songs.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.6,
            child: const Center(child: Text('No songs match your search.')),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: songs.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final song = songs[index];

        return ListTile(
          title: Text(song.title),
          subtitle: song.artist == null || song.artist!.isEmpty
              ? null
              : Text(song.artist!),
          trailing: song.key == null || song.key!.isEmpty
              ? null
              : Chip(
                  label: Text(song.key!),
                  visualDensity: VisualDensity.compact,
                ),
          onTap: () => _openSongDetail(song),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Songs'),
        actions: [
          if (_isSyncing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              tooltip: 'Sync songs',
              onPressed: _syncSongs,
              icon: const Icon(Icons.sync),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_lastSyncedAt != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Last synced: ${_formatLastSyncedAt(_lastSyncedAt!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search songs',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      ),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              textInputAction: TextInputAction.search,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _syncSongs,
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }
}
