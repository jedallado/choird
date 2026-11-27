import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/song.dart';
import '../../models/song_content_font_size.dart';
import '../../services/song_content_preferences.dart';
import '../../theme/app_colors.dart';
import '../../widgets/chord_lyric_content.dart';

class SongDetailScreen extends StatefulWidget {
  const SongDetailScreen({
    super.key,
    required this.song,
    this.isModal = false,
    this.onPrevious,
    this.onNext,
  });

  final Song song;
  final bool isModal;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

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

  void _showVideoLinks() {
    final song = widget.song;
    final links = <(String, String?)>[
      ('Soprano', song.sopranoUrl),
      ('Alto', song.altoUrl),
      ('Tenor', song.tenorUrl),
      ('Bass', song.bassUrl),
    ];

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Video Links'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (label, url) in links)
                  _VoiceLinkTile(
                    label: label,
                    url: url,
                    onOpen: _hasLink(url) ? () => _openLink(url!) : null,
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  bool _hasLink(String? url) {
    return url != null && url.trim().isNotEmpty;
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open the link.')));
    }
  }

  String _formatKeyboardTranspose(int semitones) {
    final sign = semitones > 0 ? '+' : '';
    return 'Keyboard $sign$semitones';
  }

  Widget _setupChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: AppColors.highlight,
      labelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      side: const BorderSide(color: AppColors.highlight),
    );
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
        leading: widget.isModal
            ? CloseButton(onPressed: () => Navigator.of(context).pop())
            : null,
        title: Text(song.title),
        actions: [
          if (widget.onPrevious != null || widget.onNext != null) ...[
            IconButton(
              onPressed: widget.onPrevious,
              tooltip: 'Previous song',
              iconSize: 22,
              icon: const Icon(Icons.skip_previous),
            ),
            IconButton(
              onPressed: widget.onNext,
              tooltip: 'Next song',
              iconSize: 22,
              icon: const Icon(Icons.skip_next),
            ),
          ],
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'video_links') {
                _showVideoLinks();
              } else if (value == 'toggle_bottom_bar') {
                _toggleBottomBar();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'video_links',
                child: Text('Music Links'),
              ),
              PopupMenuItem<String>(
                value: 'toggle_bottom_bar',
                child: Text(_showBottomBar ? 'Hide toolbar' : 'Show toolbar'),
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.accent),
            ),
            const SizedBox(height: 8),
          ],
          if (song.categories.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final category in song.categories)
                  Chip(label: Text(category.name)),
              ],
            ),
            SizedBox(height: _hasPerformanceBadges(song) ? 8 : 16),
          ],
          if (_hasPerformanceBadges(song)) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (song.key != null && song.key!.isNotEmpty)
                  Chip(label: Text('Key: ${song.key}')),
                if (song.capo != null && song.capo! > 0)
                  _setupChip('Capo ${song.capo}'),
                if (song.keyboardTranspose != null &&
                    song.keyboardTranspose! != 0)
                  _setupChip(_formatKeyboardTranspose(song.keyboardTranspose!)),
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
      bottomNavigationBar: _showBottomBar ? _buildBottomToolbar(context) : null,
    );
  }
}

class _VoiceLinkTile extends StatelessWidget {
  const _VoiceLinkTile({
    required this.label,
    required this.url,
    required this.onOpen,
  });

  final String label;
  final String? url;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final link = url?.trim();
    final hasLink = link != null && link.isNotEmpty;
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(
        hasLink ? link : 'No link',
        style: hasLink
            ? theme.textTheme.bodyMedium?.copyWith(color: AppColors.chords)
            : theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
      ),
      trailing: hasLink ? const Icon(Icons.open_in_new) : null,
      onTap: onOpen,
    );
  }
}
