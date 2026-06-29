import 'dart:convert';

import 'package:balance_ai/data/minimax_client.dart';
import 'package:balance_ai/domain/life_dimension.dart';
import 'package:balance_ai/domain/models.dart';
import 'package:balance_ai/state/balance_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
      'saving an assessment appends history and advances to the next dimension',
      () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(balanceControllerProvider.notifier);

    await controller.saveAssessmentAnswer(
      dimension: LifeDimensionType.health,
      rating: 7,
      transcript: 'Sleeping better but still low energy in the afternoon.',
    );

    final afterHealthSave = container.read(balanceControllerProvider);

    expect(afterHealthSave.selectedDimension, LifeDimensionType.career);
    expect(afterHealthSave.answersFor(LifeDimensionType.health), hasLength(1));
    expect(
      afterHealthSave.latestAnswerFor(LifeDimensionType.health)?.transcript,
      'Sleeping better but still low energy in the afternoon.',
    );

    await controller.saveAssessmentAnswer(
      dimension: LifeDimensionType.health,
      rating: 8,
      transcript: 'Energy is steadier after adding morning walks.',
    );

    final afterSecondHealthSave = container.read(balanceControllerProvider);

    expect(afterSecondHealthSave.selectedDimension, LifeDimensionType.career);
    expect(afterSecondHealthSave.answersFor(LifeDimensionType.health),
        hasLength(2));
    expect(
      afterSecondHealthSave
          .latestAnswerFor(LifeDimensionType.health)
          ?.transcript,
      'Energy is steadier after adding morning walks.',
    );
  });

  test('generated advice feeds recommendations and actions from saved history',
      () async {
    final client = MiniMaxProxyClient(
      baseUrl: 'http://127.0.0.1:8787',
      httpClient: MockClient((request) async {
        final payload = jsonDecode(request.body) as Map<String, dynamic>;
        expect(payload['answers'], isNotEmpty);
        return http.Response(
          jsonEncode({
            'recommendations': [
              {
                'dimension': 'health',
                'score': 82,
                'title': 'Use your afternoon energy pattern',
                'reason':
                    'Your saved history repeatedly mentions afternoon energy dips, so the next action should target that specific pattern.',
                'suggestions': [
                  'Move your walk to the first afternoon energy dip.',
                  'Add a water reminder before the slump usually starts.'
                ],
                'ctaLabel': 'Anchor the reset'
              }
            ]
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    final container = ProviderContainer(
      overrides: [minimaxProxyClientProvider.overrideWithValue(client)],
    );
    addTearDown(container.dispose);

    final controller = container.read(balanceControllerProvider.notifier);
    await controller.saveAssessmentAnswer(
      dimension: LifeDimensionType.health,
      rating: 5,
      transcript: 'Afternoons keep crashing after lunch.',
    );

    final generated = await controller.generateAiAdvice();
    final afterAdvice = container.read(balanceControllerProvider);

    expect(generated, isTrue);
    expect(afterAdvice.recommendations.first.title,
        'Use your afternoon energy pattern');
    expect(afterAdvice.actions.first.title,
        'Move your walk to the first afternoon energy dip.');
    expect(afterAdvice.adviceIsStale, isFalse);
    expect(afterAdvice.adviceAnswerCount, 1);

    await controller.saveAssessmentAnswer(
      dimension: LifeDimensionType.health,
      rating: 6,
      transcript: 'Walks helped a little, but sleep still needs work.',
    );

    final afterNewHistory = container.read(balanceControllerProvider);

    expect(afterNewHistory.recommendations.first.title,
        'Use your afternoon energy pattern');
    expect(afterNewHistory.adviceIsStale, isTrue);
  });

  test('growth actions can be reordered', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(balanceControllerProvider.notifier);
    final originalActions = container.read(balanceControllerProvider).actions;

    controller.reorderAction(0, originalActions.length - 1);

    final reorderedActions = container.read(balanceControllerProvider).actions;
    expect(reorderedActions.last.id, originalActions.first.id);
    expect(reorderedActions.first.id, originalActions[1].id);
  });

  test('advice suggestions can be added to growth focus once', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(balanceControllerProvider.notifier);
    const recommendation = Recommendation(
      dimension: LifeDimensionType.mind,
      score: 72,
      title: 'Mental Clarity',
      reason: 'Reduce context switching.',
      suggestions: ['Mute non-critical notifications for 90 minutes.'],
      ctaLabel: 'Enable Focus Mode',
    );

    final firstAdd = controller.addRecommendationSuggestionToFocus(
      recommendation: recommendation,
      suggestion: recommendation.suggestions.first,
    );
    final duplicateAdd = controller.addRecommendationSuggestionToFocus(
      recommendation: recommendation,
      suggestion: recommendation.suggestions.first,
    );

    final matchingActions = container
        .read(balanceControllerProvider)
        .actions
        .where((item) =>
            item.dimension == LifeDimensionType.mind &&
            item.title == recommendation.suggestions.first)
        .toList();

    expect(firstAdd, isTrue);
    expect(duplicateAdd, isFalse);
    expect(matchingActions, hasLength(1));
    expect(matchingActions.single.category, 'Mental Clarity');
  });
}
