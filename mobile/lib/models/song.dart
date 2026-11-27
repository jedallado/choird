import 'song_category.dart';

class Song {
  const Song({
    required this.id,
    required this.title,
    this.artist,
    this.key,
    this.capo,
    this.keyboardTranspose,
    required this.content,
    this.sopranoUrl,
    this.altoUrl,
    this.tenorUrl,
    this.bassUrl,
    this.categories = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String title;
  final String? artist;
  final String? key;
  final int? capo;
  final int? keyboardTranspose;
  final String content;
  final String? sopranoUrl;
  final String? altoUrl;
  final String? tenorUrl;
  final String? bassUrl;
  final List<SongCategory> categories;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as int,
      title: json['title'] as String,
      artist: json['artist'] as String?,
      key: json['key'] as String?,
      capo: json['capo'] as int?,
      keyboardTranspose: json['keyboardTranspose'] as int?,
      content: json['content'] as String,
      sopranoUrl: _optionalUrl(json['sopranoUrl']),
      altoUrl: _optionalUrl(json['altoUrl']),
      tenorUrl: _optionalUrl(json['tenorUrl']),
      bassUrl: _optionalUrl(json['bassUrl']),
      categories: SongCategory.listFromJson(json['categories']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

String? _optionalUrl(Object? value) {
  if (value is! String) {
    return null;
  }

  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
