class SongCategory {
  const SongCategory({required this.id, required this.name});

  final int id;
  final String name;

  factory SongCategory.fromJson(Map<String, dynamic> json) {
    return SongCategory(id: json['id'] as int, name: json['name'] as String);
  }

  static List<SongCategory> listFromJson(Object? value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map<dynamic, dynamic>>()
        .map((item) => SongCategory.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
