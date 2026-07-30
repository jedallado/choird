import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/set_list.dart';

class SetApiException implements Exception {
  SetApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class SetApi {
  SetApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<SetList>> fetchSets() async {
    final response = await _client.get(Uri.parse(ApiConfig.setsUrl));

    if (response.statusCode != 200) {
      throw SetApiException('Failed to load sets (${response.statusCode}).');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic> || decoded['data'] is! List) {
      throw SetApiException('Unexpected response format from the server.');
    }

    final sets = (decoded['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(SetList.fromJson)
        .toList();

    sets.sort((a, b) => b.scheduledFor.compareTo(a.scheduledFor));

    return sets;
  }
}
