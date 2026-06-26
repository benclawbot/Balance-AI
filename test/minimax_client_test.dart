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
}
