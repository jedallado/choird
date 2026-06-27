import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/song.dart';

class SongApiException implements Exception {
  SongApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class SongApi {
  SongApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Song>> fetchSongs() async {
    final response = await _client.get(Uri.parse(ApiConfig.songsUrl));

    if (response.statusCode != 200) {
      throw SongApiException('Failed to load songs (${response.statusCode}).');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic> || decoded['data'] is! List) {
      throw SongApiException('Unexpected response format from the server.');
    }

    return (decoded['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(Song.fromJson)
        .toList();
  }
}
