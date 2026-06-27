import 'package:flutter/material.dart';

import '../../models/song.dart';
import '../../services/song_api.dart';
import 'song_detail_screen.dart';

class SongListScreen extends StatefulWidget {
  const SongListScreen({super.key});

  @override
  State<SongListScreen> createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen> {
  final SongApi _songApi = SongApi();
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Song>> _songsFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _songsFuture = _songApi.fetchSongs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  Future<void> _refreshSongs() async {
    setState(() {
      _songsFuture = _songApi.fetchSongs();
    });

    await _songsFuture;
  }

  void _openSongDetail(Song song) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SongDetailScreen(song: song),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Songs'),
      ),
      body: Column(
        children: [
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
              onRefresh: _refreshSongs,
              child: FutureBuilder<List<Song>>(
                future: _songsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
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
                                  const Icon(
                                    Icons.error_outline,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    snapshot.error.toString(),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  FilledButton(
                                    onPressed: _refreshSongs,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  final songs = _filterSongs(snapshot.data ?? []);

                  if (songs.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.6,
                          child: Center(
                            child: Text(
                              _searchQuery.trim().isEmpty
                                  ? 'No songs yet.'
                                  : 'No songs match your search.',
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: songs.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
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
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
