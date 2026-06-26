import 'dart:convert';

import 'package:balance_ai/data/minimax_client.dart';
import 'package:balance_ai/domain/life_dimension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('recommendation requests always include all eight dimensions', () async {
    late Map<String, dynamic> payload;
    final client = MiniMaxProxyClient(
      baseUrl: 'http://127.0.0.1:8787',
      httpClient: MockClient((request) async {
        payload = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response('{"recommendations":[]}', 200);
      }),
    );

    await client.generateRecommendations(
      scores: {
        LifeDimensionType.health: const LifeDimensionScore(
          type: LifeDimensionType.health,
          score: 4,
          baseline: 7,
        ),
      },
      answers: const [],
    );

    final scores = payload['scores'] as List<dynamic>;
    expect(scores, hasLength(8));
    expect(scores.first, containsPair('type', 'health'));
    expect(scores.first, containsPair('score', 4));
    expect(scores[1], containsPair('type', 'career'));
    expect(scores[1], containsPair('score', 6));
  });

  test('direct MiniMax mode parses Anthropic-compatible model output',
      () async {
    late Uri requestUri;
    late Map<String, dynamic> payload;
    final client = MiniMaxProxyClient(
      directApiKey: 'test-key',
      directBaseUrl: 'https://api.minimax.io/anthropic',
      httpClient: MockClient((request) async {
        requestUri = request.url;
        payload = jsonDecode(request.body) as Map<String, dynamic>;
        expect(request.headers['x-api-key'], 'test-key');
        return http.Response(
          jsonEncode({
            'content': [
              {
                'type': 'text',
                'text': jsonEncode({
                  'recommendations': [
                    {
                      'dimension': 'health',
                      'score': 84,
                      'title': 'Stabilize afternoon energy',
                      'reason':
                          'Your history mentions afternoon energy dips, so the recommendation should target that pattern directly.',
                      'suggestions': [
                        'Move a short walk to the first energy dip.',
                        'Add water before the afternoon slump starts.'
                      ],
                      'ctaLabel': 'Anchor reset'
                    }
                  ]
                }),
              }
            ]
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final recommendations = await client.generateRecommendations(
      scores: {
        LifeDimensionType.health: const LifeDimensionScore(
          type: LifeDimensionType.health,
          score: 5,
          baseline: 7,
        ),
      },
      answers: const [],
    );

    expect(
        requestUri.toString(), 'https://api.minimax.io/anthropic/v1/messages');
    expect(payload['model'], 'MiniMax/M2.7');
    expect(recommendations.single.title, 'Stabilize afternoon energy');
  });
}
