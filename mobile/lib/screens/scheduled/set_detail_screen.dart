import 'package:flutter/material.dart';

import '../../models/set_list.dart';
import 'set_song_modal.dart';

class SetDetailScreen extends StatelessWidget {
  const SetDetailScreen({
    super.key,
    required this.setList,
  });

  final SetList setList;

  String _formatScheduledFor(BuildContext context, DateTime scheduledFor) {
    final localizations = MaterialLocalizations.of(context);
    final local = scheduledFor.toLocal();
    final date = localizations.formatMediumDate(local);
    final time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(local),
    );

    return '$date · $time';
  }

  void _openSongModal(
    BuildContext context,
    List<SetSongItem> songs,
    int index,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => SetSongModal(
          setSongs: songs,
          initialIndex: index,
        ),
      ),
    );
  }

  Widget _buildSongTile(
    BuildContext context,
    List<SetSongItem> songs,
    int index,
  ) {
    final setSong = songs[index];
    final song = setSong.song;
    final title = song?.title ?? 'Unknown song';
    final artist = song?.artist?.trim();
    final key = song?.key?.trim();

    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            child: Text('${setSong.position}'),
          ),
          title: Text(title),
          subtitle: artist == null || artist.isEmpty ? null : Text(artist),
          trailing: key == null || key.isEmpty
              ? null
              : Chip(
                  label: Text(key),
                  visualDensity: VisualDensity.compact,
                ),
          onTap: () => _openSongModal(context, songs, index),
        ),
        const Divider(height: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notes = setList.notes?.trim();
    final songs = [...setList.setSongs]
      ..sort((a, b) => a.position.compareTo(b.position));

    return Scaffold(
      appBar: AppBar(
        title: Text(setList.displayName),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatScheduledFor(context, setList.scheduledFor),
                  style: theme.textTheme.titleMedium,
                ),
                if (notes != null && notes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    notes,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  songs.isEmpty ? 'Songs' : 'Songs (${songs.length})',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (songs.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('No songs in this set.'),
              ),
            )
          else
            for (var index = 0; index < songs.length; index++)
              _buildSongTile(context, songs, index),
        ],
      ),
    );
  }
}
