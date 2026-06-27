class ChordPlacement {
  const ChordPlacement({
    required this.position,
    required this.chord,
  });

  final int position;
  final String chord;
}

enum ChordProLineType {
  empty,
  section,
  lyric,
}

class ChordLyricLine {
  const ChordLyricLine({
    required this.type,
    required this.lyrics,
    required this.chords,
    this.sectionLabel,
  });

  const ChordLyricLine.empty()
      : type = ChordProLineType.empty,
        lyrics = '',
        chords = const [],
        sectionLabel = null;

  const ChordLyricLine.section(String label)
      : type = ChordProLineType.section,
        lyrics = '',
        chords = const [],
        sectionLabel = label;

  const ChordLyricLine.lyric({
    required this.lyrics,
    required this.chords,
  })  : type = ChordProLineType.lyric,
        sectionLabel = null;

  final ChordProLineType type;
  final String lyrics;
  final List<ChordPlacement> chords;
  final String? sectionLabel;

  bool get hasChords => chords.isNotEmpty;
  bool get isEmpty => type == ChordProLineType.empty;
  bool get isSectionHeader => type == ChordProLineType.section;

  String get displaySectionLabel {
    if (sectionLabel != null && sectionLabel!.isNotEmpty) {
      return sectionLabel!;
    }

    if (chords.length == 1) {
      return chords.first.chord;
    }

    return '';
  }
}

class ChordProParser {
  static final _chordPattern = RegExp(r'\[([^\]]+)\]');
  static final _directivePattern = RegExp(r'^\{([^}:]+)(?::\s*(.*))?\}\s*$');

  static const _sectionKeywords = [
    'verse',
    'chorus',
    'bridge',
    'intro',
    'outro',
    'pre-chorus',
    'prechorus',
    'interlude',
    'tag',
    'coda',
    'ending',
    'instrumental',
    'solo',
    'break',
  ];

  static const _directiveAliases = {
    'sov': 'start_of_verse',
    'eov': 'end_of_verse',
    'soc': 'start_of_chorus',
    'eoc': 'end_of_chorus',
    'sob': 'start_of_bridge',
    'eob': 'end_of_bridge',
    'sot': 'start_of_tab',
    'eot': 'end_of_tab',
    'sog': 'start_of_grid',
    'eog': 'end_of_grid',
  };

  static const _metadataDirectives = {
    'title',
    'artist',
    'subtitle',
    'composer',
    'lyricist',
    'copyright',
    'album',
    'year',
    'key',
    'tempo',
    'time',
    'capo',
  };

  static const _endDirectives = {
    'end_of_verse',
    'end_of_chorus',
    'end_of_bridge',
    'end_of_tab',
    'end_of_grid',
  };

  static List<ChordLyricLine> parse(String content) {
    final lines = <ChordLyricLine>[];

    for (final rawLine in content.split('\n')) {
      final parsed = _parseLine(rawLine);
      if (parsed != null) {
        lines.add(parsed);
      }
    }

    return lines;
  }

  static ChordLyricLine? _parseLine(String line) {
    final directiveMatch = _directivePattern.firstMatch(line.trim());
    if (directiveMatch != null) {
      return _parseDirective(directiveMatch);
    }

    return _parseLyricLine(line);
  }

  static ChordLyricLine? _parseDirective(RegExpMatch match) {
    final key = _normalizeDirectiveKey(match.group(1)!);
    final value = match.group(2)?.trim();

    if (_metadataDirectives.contains(key) || _endDirectives.contains(key)) {
      return null;
    }

    if (key == 'comment') {
      if (value == null || value.isEmpty) {
        return null;
      }

      return ChordLyricLine.section(value);
    }

    if (key.startsWith('start_of_')) {
      final sectionName = key.substring('start_of_'.length);
      final label = value?.isNotEmpty == true ? value! : _defaultSectionLabel(sectionName);
      return ChordLyricLine.section(label);
    }

    if (key == 'define' || key == 'chord' || key == 'image') {
      return null;
    }

    if (value != null && value.isNotEmpty) {
      return ChordLyricLine.section(value);
    }

    return null;
  }

  static String _normalizeDirectiveKey(String rawKey) {
    final normalized = rawKey.trim().toLowerCase().replaceAll(' ', '_');
    return _directiveAliases[normalized] ?? normalized;
  }

  static String _defaultSectionLabel(String sectionName) {
    return switch (sectionName) {
      'verse' => 'Verse',
      'chorus' => 'Chorus',
      'bridge' => 'Bridge',
      'tab' => 'Tab',
      'grid' => 'Grid',
      _ => sectionName
          .split('_')
          .map(
            (part) => part.isEmpty
                ? part
                : '${part[0].toUpperCase()}${part.substring(1)}',
          )
          .join(' '),
    };
  }

  static ChordLyricLine _parseLyricLine(String line) {
    if (line.isEmpty) {
      return const ChordLyricLine.empty();
    }

    final chords = <ChordPlacement>[];
    final lyricsBuffer = StringBuffer();
    var lastEnd = 0;

    for (final match in _chordPattern.allMatches(line)) {
      lyricsBuffer.write(line.substring(lastEnd, match.start));
      chords.add(
        ChordPlacement(
          position: lyricsBuffer.length,
          chord: match.group(1)!,
        ),
      );
      lastEnd = match.end;
    }

    lyricsBuffer.write(line.substring(lastEnd));
    final lyrics = lyricsBuffer.toString();

    if (chords.length == 1 &&
        lyrics.trim().isEmpty &&
        chords.first.position == 0 &&
        _looksLikeSectionLabel(chords.first.chord)) {
      return ChordLyricLine.section(chords.first.chord);
    }

    return ChordLyricLine.lyric(
      lyrics: lyrics,
      chords: chords,
    );
  }

  static bool _looksLikeSectionLabel(String text) {
    if (text.contains(' ')) {
      return true;
    }

    final lower = text.toLowerCase();
    return _sectionKeywords.any(lower.contains);
  }

  static String buildChordLine(ChordLyricLine line) {
    if (line.chords.isEmpty) {
      return '';
    }

    final placedChords = <({int position, String chord})>[];
    var nextAvailable = 0;

    for (final chord in line.chords) {
      final position = chord.position > nextAvailable
          ? chord.position
          : nextAvailable;
      placedChords.add((position: position, chord: chord.chord));
      nextAvailable = position + chord.chord.length + 1;
    }

    var length = line.lyrics.length;
    for (final placed in placedChords) {
      final end = placed.position + placed.chord.length;
      if (end > length) {
        length = end;
      }
    }

    final buffer = List.filled(length, ' ');

    for (final placed in placedChords) {
      for (var i = 0; i < placed.chord.length; i++) {
        final index = placed.position + i;
        if (index < buffer.length) {
          buffer[index] = placed.chord[i];
        }
      }
    }

    return buffer.join().trimRight();
  }
}
