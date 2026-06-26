import 'life_dimension.dart';
import 'models.dart';
import 'scoring.dart';

class RecommendationEngine {
  const RecommendationEngine({this.scoringEngine = const BalanceScoringEngine()});

  final BalanceScoringEngine scoringEngine;

  List<Recommendation> generateFallbackRecommendations(
    Map<LifeDimensionType, LifeDimensionScore> scores,
  ) {
    final priorities = scoringEngine.priorityDimensions(scores, limit: 3);
    return priorities.map(_buildRecommendation).toList(growable: false);
  }

  List<ActionItem> generateActionPlan(List<Recommendation> recommendations) {
    var index = 0;
    return recommendations.expand((recommendation) {
      return recommendation.suggestions.take(2).map((suggestion) {
        index += 1;
        return ActionItem(
          id: 'action-$index-${recommendation.dimension.slug}',
          title: suggestion,
          category: _categoryFor(recommendation.dimension),
          dimension: recommendation.dimension,
        );
      });
    }).toList(growable: false);
  }

  Recommendation _buildRecommendation(LifeDimensionScore score) {
    return switch (score.type) {
      LifeDimensionType.health => Recommendation(
          dimension: score.type,
          score: score.scorePercent,
          title: 'Health & Energy',
          reason:
              'Your energy score is below your baseline. Start with one low-friction recovery habit instead of a full routine rebuild.',
          suggestions: const [
            'Schedule a 15-minute morning walk.',
            'Move hydration earlier in the day.',
            'Set a fixed wind-down cue 30 minutes before sleep.',
          ],
          ctaLabel: 'Start Energy Reset',
        ),
      LifeDimensionType.career => Recommendation(
          dimension: score.type,
          score: score.scorePercent,
          title: 'Career Stability',
          reason:
              'Your work score suggests friction around focus, pacing, or control. Protect one uninterrupted block before adding more workload.',
          suggestions: const [
            'Block one 50-minute deep-work window today.',
            'Write the one outcome that would make today successful.',
            'Defer non-critical messages for one hour.',
          ],
          ctaLabel: 'Protect Focus',
        ),
      LifeDimensionType.finance => Recommendation(
          dimension: score.type,
          score: score.scorePercent,
          title: 'Financial Clarity',
          reason:
              'Financial uncertainty can drain mental resilience. The first intervention is visibility, not austerity.',
          suggestions: const [
            'Review the next 7 days of expected expenses.',
            'Create one small spending guardrail for today.',
            'Move one recurring payment reminder into your calendar.',
          ],
          ctaLabel: 'Review Cash Flow',
        ),
      LifeDimensionType.social => Recommendation(
          dimension: score.type,
          score: score.scorePercent,
          title: 'Social Connection',
          reason:
              'Your connection score is below baseline. Small meaningful interactions are more realistic than broad social plans.',
          suggestions: const [
            'Schedule a 10-minute catch-up with one person.',
            'Send one sincere gratitude message today.',
            'Plan one low-pressure social touchpoint this week.',
          ],
          ctaLabel: 'Plan a Call',
        ),
      LifeDimensionType.mind => Recommendation(
          dimension: score.type,
          score: score.scorePercent,
          title: 'Mental Clarity',
          reason:
              'Your mind score points to cognitive load or context switching. Reduce input noise before pushing for productivity.',
          suggestions: const [
            'Mute non-critical notifications for 90 minutes.',
            'Do a 3-minute breathing reset before the next work block.',
            'Write down the recurring thought that keeps pulling attention.',
          ],
          ctaLabel: 'Enable Focus Mode',
        ),
      LifeDimensionType.home => Recommendation(
          dimension: score.type,
          score: score.scorePercent,
          title: 'Home Support',
          reason:
              'Your environment is not giving enough frictionless support. One visible reset can improve multiple routines.',
          suggestions: const [
            'Clear one high-friction surface for 5 minutes.',
            'Prepare tomorrow’s first object before bed.',
            'Move one distracting item out of the main room.',
          ],
          ctaLabel: 'Reset Space',
        ),
      LifeDimensionType.growth => Recommendation(
          dimension: score.type,
          score: score.scorePercent,
          title: 'Personal Growth',
          reason:
              'Your growth system needs a smaller next step. Convert ambition into one measurable action.',
          suggestions: const [
            'Pick one 20-minute learning block this week.',
            'Write one sentence about what you learned today.',
            'Choose the smallest possible version of your current goal.',
          ],
          ctaLabel: 'Set Growth Step',
        ),
      LifeDimensionType.leisure => Recommendation(
          dimension: score.type,
          score: score.scorePercent,
          title: 'Leisure & Recovery',
          reason:
              'Passive downtime may not be restoring you enough. Add deliberate joy rather than only reducing obligations.',
          suggestions: const [
            'Schedule 20 minutes of guilt-free recovery.',
            'Choose one playful activity before the day ends.',
            'Stop one draining activity 15 minutes earlier tonight.',
          ],
          ctaLabel: 'Plan Recovery',
        ),
    };
  }

  String _categoryFor(LifeDimensionType type) => switch (type) {
        LifeDimensionType.health => 'Physical Balance',
        LifeDimensionType.career => 'Deep Work',
        LifeDimensionType.finance => 'Financial Clarity',
        LifeDimensionType.social => 'Connection',
        LifeDimensionType.mind => 'Mental Clarity',
        LifeDimensionType.home => 'Environment',
        LifeDimensionType.growth => 'Habit Formation',
        LifeDimensionType.leisure => 'Recovery',
      };
}
