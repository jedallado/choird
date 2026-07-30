class SetSongSummary {
  const SetSongSummary({
    required this.id,
    required this.title,
    this.artist,
    this.key,
    this.capo,
    this.keyboardTranspose,
  });

  final int id;
  final String title;
  final String? artist;
  final String? key;
  final int? capo;
  final int? keyboardTranspose;

  factory SetSongSummary.fromJson(Map<String, dynamic> json) {
    return SetSongSummary(
      id: json['id'] as int,
      title: json['title'] as String,
      artist: json['artist'] as String?,
      key: json['key'] as String?,
      capo: json['capo'] as int?,
      keyboardTranspose: json['keyboardTranspose'] as int?,
    );
  }
}

class SetSongItem {
  const SetSongItem({
    required this.id,
    required this.songId,
    required this.position,
    this.song,
  });

  final int id;
  final int songId;
  final int position;
  final SetSongSummary? song;

  factory SetSongItem.fromJson(Map<String, dynamic> json) {
    final songJson = json['song'];

    return SetSongItem(
      id: json['id'] as int,
      songId: json['songId'] as int,
      position: json['position'] as int,
      song: songJson is Map<String, dynamic>
          ? SetSongSummary.fromJson(songJson)
          : null,
    );
  }
}

class SetList {
  const SetList({
    required this.id,
    this.name,
    required this.scheduledFor,
    required this.createdByUserId,
    this.notes,
    required this.setSongs,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String? name;
  final DateTime scheduledFor;
  final int createdByUserId;
  final String? notes;
  final List<SetSongItem> setSongs;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get displayName {
    final value = name?.trim();
    if (value == null || value.isEmpty) {
      return 'Untitled set';
    }

    return value;
  }

  factory SetList.fromJson(Map<String, dynamic> json) {
    final setSongsJson = json['setSongs'];

    return SetList(
      id: json['id'] as int,
      name: json['name'] as String?,
      scheduledFor: DateTime.parse(json['scheduledFor'] as String),
      createdByUserId: json['createdByUserId'] as int,
      notes: json['notes'] as String?,
      setSongs: setSongsJson is List
          ? setSongsJson
              .cast<Map<String, dynamic>>()
              .map(SetSongItem.fromJson)
              .toList()
          : const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
