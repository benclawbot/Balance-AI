import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../domain/life_dimension.dart';
import '../../domain/models.dart';
import '../../state/balance_controller.dart';
import '../../state/balance_state.dart';
import '../components/app_chrome.dart';

class AdviceScreen extends ConsumerStatefulWidget {
  const AdviceScreen({super.key});

  @override
  ConsumerState<AdviceScreen> createState() => _AdviceScreenState();
}

class _AdviceScreenState extends ConsumerState<AdviceScreen> {
  int? _autoRefreshAttemptedForAnswerCount;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(balanceControllerProvider);
    final controller = ref.read(balanceControllerProvider.notifier);
    _scheduleHistoryRefreshIfNeeded(state, controller);

    return Column(
      children: [
        const BalanceTopBar(),
        Expanded(
          child: ScreenScroll(
            children: [
              const SectionEyebrow('Personalized Insights'),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  text: 'Focus Areas for\n',
                  children: [
                    TextSpan(
                      text: 'Growth',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: MindfulColors.clayAccent,
                            fontSize: 44,
                          ),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(fontSize: 44),
              ),
              const SizedBox(height: 10),
              Text(
                _contextDescription(state),
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: MindfulColors.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: state.isGeneratingAdvice
                    ? null
                    : () async {
                        await controller.generateAiAdvice();
                      },
                icon: state.isGeneratingAdvice
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.auto_awesome_rounded),
                label: Text(state.isGeneratingAdvice
                    ? 'READING HISTORY...'
                    : _buttonLabel(state)),
              ),
              if (state.lastError != null) ...[
                const SizedBox(height: 12),
                TonalCard(
                  color: MindfulColors.surfaceContainer,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_rounded,
                          color: MindfulColors.clayAccent),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(state.lastError!,
                              style: Theme.of(context).textTheme.bodyMedium)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 22),
              ...state.recommendations.map(
                (recommendation) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: RecommendationCard(
                    recommendation: recommendation,
                    focusActions: state.actions,
                    onAddSuggestion: (suggestion) {
                      final added =
                          controller.addRecommendationSuggestionToFocus(
                        recommendation: recommendation,
                        suggestion: suggestion,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            added
                                ? 'Added to Today\'s Focus.'
                                : 'Already in Today\'s Focus.',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TonalCard(
                color: MindfulColors.inkBlack,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'History Context',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _historyContext(state),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color:
                                        Colors.white.withValues(alpha: 0.72)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 18),
                    Column(
                      children: [
                        Text('${state.answers.length}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(color: Colors.white)),
                        Text('UPDATES',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                    color:
                                        Colors.white.withValues(alpha: 0.62))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _scheduleHistoryRefreshIfNeeded(
      BalanceState state, BalanceController controller) {
    final answerCount = state.answers.length;
    if (answerCount == 0 || state.isGeneratingAdvice || !state.adviceIsStale) {
      return;
    }
    if (_autoRefreshAttemptedForAnswerCount == answerCount) return;

    _autoRefreshAttemptedForAnswerCount = answerCount;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      controller.generateAiAdvice();
    });
  }

  String _contextDescription(BalanceState state) {
    if (state.answers.isEmpty) {
      return 'Add details in Assess, then this section will use your saved dimension history to generate context-specific recommendations.';
    }
    if (state.isGeneratingAdvice) {
      return 'MiniMax is reading ${state.answers.length} saved updates across ${state.assessedDimensionCount} dimensions and turning them into recommendations.';
    }
    if (state.hasGeneratedAdvice && !state.adviceIsStale) {
      return 'These recommendations are generated from ${state.answers.length} saved updates across ${state.assessedDimensionCount} dimensions.';
    }
    if (state.hasGeneratedAdvice && state.adviceIsStale) {
      return 'Your assessment history changed since the last AI pass. Refresh to fold the newest details into the recommendations.';
    }
    return 'Your saved history is ready. Generate from history to replace generic fallback advice with context-specific recommendations.';
  }

  String _buttonLabel(BalanceState state) {
    if (!state.hasGeneratedAdvice) return 'GENERATE FROM HISTORY';
    if (state.adviceIsStale) return 'REFRESH FROM HISTORY';
    return 'REFRESH WITH MINIMAX M2.7';
  }

  String _historyContext(BalanceState state) {
    if (state.answers.isEmpty) {
      return 'No assessment updates have been saved yet.';
    }
    final latest = state.answers.last;
    return 'Latest saved update: ${latest.dimension.label}, rated ${latest.rating}/10. Actions below are refreshed from the current recommendation set.';
  }
}

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.recommendation,
    required this.focusActions,
    required this.onAddSuggestion,
  });

  final Recommendation recommendation;
  final List<ActionItem> focusActions;
  final ValueChanged<String> onAddSuggestion;

  @override
  Widget build(BuildContext context) {
    return TonalCard(
      color: MindfulColors.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    MindfulColors.clayAccent.withValues(alpha: 0.16),
                foregroundColor: MindfulColors.clayAccent,
                child: Icon(recommendation.dimension.icon),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SCORE: ${recommendation.score}/100',
                        style: Theme.of(context).textTheme.labelSmall),
                    Text(recommendation.title,
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '"${recommendation.reason}"',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: MindfulColors.onSurfaceVariant),
          ),
          const SizedBox(height: 18),
          Text('SUGGESTIONS', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 10),
          ...recommendation.suggestions.map((suggestion) {
            final isFocused = focusActions.any(
              (item) =>
                  item.dimension == recommendation.dimension &&
                  item.title.trim().toLowerCase() ==
                      suggestion.trim().toLowerCase(),
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 7),
                    child: Icon(Icons.circle,
                        size: 7, color: MindfulColors.clayAccent),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(suggestion,
                          style: Theme.of(context).textTheme.bodyMedium)),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed:
                        isFocused ? null : () => onAddSuggestion(suggestion),
                    icon: Icon(
                      isFocused ? Icons.check_rounded : Icons.add_rounded,
                      size: 18,
                    ),
                    label: Text(isFocused ? 'ADDED' : 'FOCUS'),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {},
            child: Text(recommendation.ctaLabel.toUpperCase()),
          ),
        ],
      ),
    );
  }
}
