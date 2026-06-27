import 'package:flutter/material.dart';

import '../../models/song.dart';
import '../../theme/app_colors.dart';
import '../../widgets/chord_lyric_content.dart';

class SongDetailScreen extends StatefulWidget {
  const SongDetailScreen({
    super.key,
    required this.song,
  });

  final Song song;

  @override
  State<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> {
  bool _showChords = true;

  void _toggleChords() {
    setState(() {
      _showChords = !_showChords;
    });
  }

  bool _hasPerformanceBadges(Song song) {
    return (song.key != null && song.key!.isNotEmpty) ||
        (song.capo != null && song.capo! > 0) ||
        (song.keyboardTranspose != null && song.keyboardTranspose! != 0);
  }

  String _formatKeyboardTranspose(int semitones) {
    final sign = semitones > 0 ? '+' : '';
    return 'Keyboard $sign$semitones';
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.song;

    return Scaffold(
      appBar: AppBar(
        title: Text(song.title),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'toggle_chords') {
                _toggleChords();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'toggle_chords',
                child: Text(_showChords ? 'Hide Chords' : 'Show Chords'),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (song.artist != null && song.artist!.isNotEmpty) ...[
            Text(
              song.artist!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (_hasPerformanceBadges(song)) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (song.key != null && song.key!.isNotEmpty)
                  Chip(label: Text('Key: ${song.key}')),
                if (song.capo != null && song.capo! > 0)
                  Chip(label: Text('Capo ${song.capo}')),
                if (song.keyboardTranspose != null && song.keyboardTranspose! != 0)
                  Chip(
                    label: Text(
                      _formatKeyboardTranspose(song.keyboardTranspose!),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          ChordLyricContent(
            content: song.content,
            showChords: _showChords,
          ),
        ],
      ),
    );
  }
}
