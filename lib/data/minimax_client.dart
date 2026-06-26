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
    String? directApiKey,
    String? directBaseUrl,
    String? directModel,
  })  : _httpClient = httpClient ?? http.Client(),
        _baseUrl = baseUrl ??
            const String.fromEnvironment(
              'BALANCE_API_BASE_URL',
              defaultValue: 'http://localhost:8787',
            ),
        _directApiKey = directApiKey ??
            const String.fromEnvironment(
              'BALANCE_MINIMAX_API_KEY',
              defaultValue: '',
            ),
        _directBaseUrl = directBaseUrl ??
            const String.fromEnvironment(
              'BALANCE_MINIMAX_BASE_URL',
              defaultValue: 'https://api.minimax.io/anthropic',
            ),
        _directModel = directModel ??
            const String.fromEnvironment(
              'BALANCE_MINIMAX_MODEL',
              defaultValue: 'MiniMax/M2.7',
            );

  static const _systemPrompt =
      'You are Balance AI, a practical life-balance assistant. Return only valid JSON. Do not give medical, legal, or financial advice. Use low-risk behavioral suggestions.';

  final http.Client _httpClient;
  final String _baseUrl;
  final String _directApiKey;
  final String _directBaseUrl;
  final String _directModel;

  Future<List<Recommendation>> generateRecommendations({
    required Map<LifeDimensionType, LifeDimensionScore> scores,
    required List<AssessmentAnswer> answers,
  }) async {
    if (_directApiKey.trim().isNotEmpty) {
      return _generateDirectMiniMaxRecommendations(
          scores: scores, answers: answers);
    }
    return _generateProxyRecommendations(scores: scores, answers: answers);
  }

  Future<List<Recommendation>> _generateProxyRecommendations({
    required Map<LifeDimensionType, LifeDimensionScore> scores,
    required List<AssessmentAnswer> answers,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/recommendations');
    final response = await _httpClient.post(
      uri,
      headers: const {'content-type': 'application/json'},
      body: jsonEncode(_requestPayload(scores: scores, answers: answers)),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw MiniMaxProxyException(
        'Recommendation request failed: ${response.statusCode} ${response.body}',
      );
    }
    return _parseRecommendationEnvelope(response.body);
  }

  Future<List<Recommendation>> _generateDirectMiniMaxRecommendations({
    required Map<LifeDimensionType, LifeDimensionScore> scores,
    required List<AssessmentAnswer> answers,
  }) async {
    final uri = Uri.parse('${_trimSlash(_directBaseUrl)}/v1/messages');
    final response = await _httpClient.post(
      uri,
      headers: {
        'accept': 'application/json',
        'content-type': 'application/json',
        'x-api-key': _directApiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': _directModel,
        'max_tokens': 1400,
        'temperature': 0.4,
        'system': _systemPrompt,
        'messages': [
          {
            'role': 'user',
            'content':
                _buildRecommendationPrompt(scores: scores, answers: answers),
          },
        ],
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw MiniMaxProxyException(
        'MiniMax request failed: ${response.statusCode} ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final blocks = decoded['content'] as List<dynamic>? ?? const [];
    final text = blocks
        .whereType<Map<String, dynamic>>()
        .map((block) => block['text']?.toString() ?? '')
        .where((item) => item.trim().isNotEmpty)
        .join('\n')
        .trim();
    if (text.isEmpty) {
      throw MiniMaxProxyException('MiniMax returned an empty response');
    }
    return _parseRecommendationEnvelope(_stripJsonFence(text));
  }

  Map<String, dynamic> _requestPayload({
    required Map<LifeDimensionType, LifeDimensionScore> scores,
    required List<AssessmentAnswer> answers,
  }) {
    return {
      'scores': LifeDimensionType.values.map((dimension) {
        return (scores[dimension] ??
                LifeDimensionScore(type: dimension, score: 6, baseline: 7))
            .toJson();
      }).toList(),
      'answers': answers.map((answer) => answer.toJson()).toList(),
    };
  }

  String _buildRecommendationPrompt({
    required Map<LifeDimensionType, LifeDimensionScore> scores,
    required List<AssessmentAnswer> answers,
  }) {
    final payload = _requestPayload(scores: scores, answers: answers);
    return jsonEncode({
      'task':
          'Generate the top 3 life-balance recommendations for a Flutter app. Focus on dimensions below baseline or with low user rating. Suggestions must be actionable today and low-risk.',
      'canonicalDimensions':
          LifeDimensionType.values.map((dimension) => dimension.slug).toList(),
      'requiredJsonShape': {
        'recommendations': [
          {
            'dimension':
                'health | career | finance | social | mind | home | growth | leisure',
            'score': 'integer 0-100 matching urgency/score display',
            'title': 'short card title',
            'reason':
                'specific explanation grounded in scores and answer transcripts',
            'suggestions': ['2-4 concrete low-risk actions'],
            'ctaLabel': 'short imperative button label',
          },
        ],
      },
      'safetyRules': [
        'Do not diagnose health or mental-health conditions.',
        'Do not provide investment, legal, medical, or therapy instructions.',
        'If finance is low, recommend visibility and budgeting reflection, not investment products.',
        'If health or mind is low, recommend habits and support-seeking, not clinical claims.',
      ],
      'scores': payload['scores'],
      'dimensionHistory': _buildDimensionHistory(answers),
      'recentAnswers': answers
          .takeLast(24)
          .map((answer) => {
                ...answer.toJson(),
                'transcript': _truncate(answer.transcript, 1800),
              })
          .toList(),
    });
  }

  List<Map<String, dynamic>> _buildDimensionHistory(
      List<AssessmentAnswer> answers) {
    return LifeDimensionType.values.map((dimension) {
      final dimensionAnswers = answers
          .where((answer) => answer.dimension == dimension)
          .toList(growable: false);
      final latest = dimensionAnswers.isEmpty ? null : dimensionAnswers.last;
      return {
        'dimension': dimension.slug,
        'savedUpdates': dimensionAnswers.length,
        'latest': latest == null
            ? null
            : {
                'rating': latest.rating,
                'createdAt': latest.createdAt.toIso8601String(),
                'transcript': _truncate(latest.transcript, 1800),
              },
        'previousUpdates': dimensionAnswers
            .skip(
                (dimensionAnswers.length - 5).clamp(0, dimensionAnswers.length))
            .take((dimensionAnswers.length - 1).clamp(0, 4))
            .map((answer) => {
                  'rating': answer.rating,
                  'createdAt': answer.createdAt.toIso8601String(),
                  'transcript': _truncate(answer.transcript, 900),
                })
            .toList(),
      };
    }).toList(growable: false);
  }

  List<Recommendation> _parseRecommendationEnvelope(String body) {
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    final items = decoded['recommendations'] as List<dynamic>? ?? const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(Recommendation.fromJson)
        .where((item) => item.suggestions.isNotEmpty)
        .take(3)
        .toList(growable: false);
  }

  String _stripJsonFence(String content) {
    return content
        .trim()
        .replaceFirst(RegExp(r'^```(?:json)?\s*', caseSensitive: false), '')
        .replaceFirst(RegExp(r'\s*```$', caseSensitive: false), '')
        .trim();
  }

  String _truncate(String value, int maxLength) {
    if (value.length <= maxLength) return value;
    return '${value.substring(0, maxLength - 15).trimRight()} [truncated]';
  }

  String _trimSlash(String value) => value.replaceFirst(RegExp(r'/+$'), '');
}

extension _TakeLastExtension<T> on Iterable<T> {
  Iterable<T> takeLast(int count) {
    final items = toList(growable: false);
    return items.skip((items.length - count).clamp(0, items.length));
  }
}
