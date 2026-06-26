import 'package:balance_ai/domain/life_dimension.dart';
import 'package:balance_ai/domain/models.dart';
import 'package:balance_ai/domain/recommendation_engine.dart';
import 'package:balance_ai/domain/scoring.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BalanceScoringEngine', () {
    test('computes the overall score from dimension values', () {
      final scores = defaultDimensionScores();
      final overall = const BalanceScoringEngine().overallScore(scores);
      expect(overall, greaterThan(0));
      expect(overall, lessThanOrEqualTo(10));
    });

    test('low dimensions are prioritized first', () {
      final scores = defaultDimensionScores();
      final priorities = const BalanceScoringEngine().priorityDimensions(scores, limit: 3);
      expect(priorities, hasLength(3));
      expect(priorities.first.type, anyOf(LifeDimensionType.finance, LifeDimensionType.social, LifeDimensionType.health));
    });

    test('assessment answer updates the selected dimension', () {
      final engine = const BalanceScoringEngine();
      final answer = AssessmentAnswer(
        dimension: LifeDimensionType.mind,
        rating: 4,
        transcript: 'I feel stressed and overwhelmed by context switching.',
        createdAt: DateTime(2026),
      );
      final updated = engine.applyAnswer(current: defaultDimensionScores(), answer: answer);
      expect(updated[LifeDimensionType.mind]!.score, lessThanOrEqualTo(4));
      expect(updated[LifeDimensionType.mind]!.note, contains('stressed'));
    });
  });

  group('RecommendationEngine', () {
    test('produces three fallback recommendations with suggestions', () {
      final recommendations = const RecommendationEngine().generateFallbackRecommendations(defaultDimensionScores());
      expect(recommendations, hasLength(3));
      expect(recommendations.every((item) => item.suggestions.isNotEmpty), isTrue);
    });

    test('creates actionable steps from recommendations', () {
      final engine = const RecommendationEngine();
      final recommendations = engine.generateFallbackRecommendations(defaultDimensionScores());
      final actions = engine.generateActionPlan(recommendations);
      expect(actions.length, greaterThanOrEqualTo(3));
      expect(actions.every((item) => item.completed == false), isTrue);
    });
  });
}
