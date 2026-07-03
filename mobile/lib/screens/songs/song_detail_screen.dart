import 'package:flutter/material.dart';

import '../../models/song.dart';
import '../../models/song_content_font_size.dart';
import '../../services/song_content_preferences.dart';
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
  final SongContentPreferences _preferences = SongContentPreferences();

  bool _showChords = true;
  bool _showBottomBar = true;
  SongContentFontSize _fontSize = SongContentFontSize.m;

  @override
  void initState() {
    super.initState();
    _loadFontSize();
  }

  Future<void> _loadFontSize() async {
    final fontSize = await _preferences.getFontSize();
    if (!mounted) {
      return;
    }

    setState(() {
      _fontSize = fontSize;
    });
  }

  void _toggleChords() {
    setState(() {
      _showChords = !_showChords;
    });
  }

  void _toggleBottomBar() {
    setState(() {
      _showBottomBar = !_showBottomBar;
    });
  }

  Future<void> _setFontSize(SongContentFontSize fontSize) async {
    if (_fontSize == fontSize) {
      return;
    }

    setState(() {
      _fontSize = fontSize;
    });

    await _preferences.setFontSize(fontSize);
  }

  void _decreaseFontSize() {
    if (!_fontSize.canDecrease) {
      return;
    }

    _setFontSize(_fontSize.smaller);
  }

  void _increaseFontSize() {
    if (!_fontSize.canIncrease) {
      return;
    }

    _setFontSize(_fontSize.larger);
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

  Widget _buildBottomToolbar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      child: SafeArea(
        top: false,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.4),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  onPressed: _toggleChords,
                  tooltip: _showChords ? 'Hide chords' : 'Show chords',
                  style: IconButton.styleFrom(
                    backgroundColor: _showChords
                        ? colorScheme.primaryContainer
                        : null,
                    foregroundColor: _showChords
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface,
                  ),
                  icon: const Icon(Icons.music_note),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _fontSize.canDecrease ? _decreaseFontSize : null,
                  tooltip: 'Smaller text',
                  icon: const Text(
                    'A−',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    '${_fontSize.fontSize.toInt()}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _fontSize.canIncrease ? _increaseFontSize : null,
                  tooltip: 'Larger text',
                  icon: const Text(
                    'A+',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
              if (value == 'toggle_bottom_bar') {
                _toggleBottomBar();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'toggle_bottom_bar',
                child: Text(
                  _showBottomBar ? 'Hide toolbar' : 'Show toolbar',
                ),
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
            fontSize: _fontSize.fontSize,
          ),
        ],
      ),
      bottomNavigationBar:
          _showBottomBar ? _buildBottomToolbar(context) : null,
    );
  }
}
