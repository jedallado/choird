class Song {
  const Song({
    required this.id,
    required this.title,
    this.artist,
    this.key,
    this.capo,
    this.keyboardTranspose,
    required this.content,
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
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
