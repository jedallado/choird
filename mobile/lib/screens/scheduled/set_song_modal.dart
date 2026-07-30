import 'package:flutter/material.dart';

import '../../models/set_list.dart';
import '../../models/song.dart';
import '../../services/song_repository.dart';
import '../songs/song_detail_screen.dart';

class SetSongModal extends StatefulWidget {
  const SetSongModal({
    super.key,
    required this.setSongs,
    required this.initialIndex,
    SongRepository? repository,
  }) : _repository = repository;

  final List<SetSongItem> setSongs;
  final int initialIndex;
  final SongRepository? _repository;

  @override
  State<SetSongModal> createState() => _SetSongModalState();
}

class _SetSongModalState extends State<SetSongModal> {
  late final SongRepository _repository =
      widget._repository ?? SongRepository();
  final Map<int, Song> _songCache = {};

  late int _currentIndex;
  late Future<Song> _songFuture;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _songFuture = _loadSong(_currentIndex);
  }

  Future<Song> _loadSong(int index) async {
    final songId = widget.setSongs[index].songId;
    final cachedSong = _songCache[songId];
    if (cachedSong != null) {
      return cachedSong;
    }

    final song = await _repository.getSong(songId);
    _songCache[songId] = song;
    return song;
  }

  void _goTo(int index) {
    if (index < 0 || index >= widget.setSongs.length || index == _currentIndex) {
      return;
    }

    setState(() {
      _currentIndex = index;
      _songFuture = _loadSong(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Song>(
      future: _songFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              leading: CloseButton(
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text('Loading song'),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              leading: CloseButton(
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text('Song'),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _songFuture = _loadSong(_currentIndex);
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final song = snapshot.data!;

        return SongDetailScreen(
          key: ValueKey(song.id),
          song: song,
          isModal: true,
          onPrevious: _currentIndex > 0
              ? () => _goTo(_currentIndex - 1)
              : null,
          onNext: _currentIndex < widget.setSongs.length - 1
              ? () => _goTo(_currentIndex + 1)
              : null,
        );
      },
    );
  }
}
