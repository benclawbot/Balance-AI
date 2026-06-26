import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/life_dimension.dart';
import '../domain/models.dart';

class MiniMaxProxyException implements Exception {
  MiniMaxProxyException(this.message);
  final String message;

  @override
  String toString() => 'MiniMaxProxyException: $message';
}

class MiniMaxProxyClient {
  MiniMaxProxyClient({
    http.Client? httpClient,
    String? baseUrl,
  })  : _httpClient = httpClient ?? http.Client(),
        _baseUrl = baseUrl ??
            const String.fromEnvironment(
              'BALANCE_API_BASE_URL',
              defaultValue: 'http://localhost:8787',
            );

  final http.Client _httpClient;
  final String _baseUrl;

  Future<List<Recommendation>> generateRecommendations({
    required Map<LifeDimensionType, LifeDimensionScore> scores,
    required List<AssessmentAnswer> answers,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/recommendations');
    final response = await _httpClient.post(
      uri,
      headers: const {'content-type': 'application/json'},
      body: jsonEncode({
        'scores': LifeDimensionType.values.map((dimension) {
          return (scores[dimension] ??
                  LifeDimensionScore(type: dimension, score: 6, baseline: 7))
              .toJson();
        }).toList(),
        'answers': answers.map((answer) => answer.toJson()).toList(),
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw MiniMaxProxyException(
          'Recommendation request failed: ${response.statusCode} ${response.body}');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final items = decoded['recommendations'] as List<dynamic>? ?? const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(Recommendation.fromJson)
        .where((item) => item.suggestions.isNotEmpty)
        .toList(growable: false);
  }
}
