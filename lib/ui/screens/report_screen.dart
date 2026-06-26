import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../domain/models.dart';
import '../../domain/scoring.dart';
import '../../state/balance_controller.dart';
import '../components/app_chrome.dart';
import '../components/report_charts.dart';

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(balanceControllerProvider);
    final scoring = const BalanceScoringEngine();
    final overall = scoring.overallPercent(state.dimensions);
    final trendPoints = const [
      TrendPoint(label: 'Jan', value: 74),
      TrendPoint(label: 'Feb', value: 76),
      TrendPoint(label: 'Mar', value: 72),
      TrendPoint(label: 'Apr', value: 79),
      TrendPoint(label: 'May', value: 81),
      TrendPoint(label: 'Jun', value: 84),
    ];

    return Column(
      children: [
        BalanceTopBar(title: 'Full Report'),
        Expanded(
          child: ScreenScroll(
            children: [
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => context.go('/growth'),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Growth'),
                  ),
                ],
              ),
              const SectionEyebrow('Analytics Engine'),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  text: 'Visualizing your journey to\n',
                  children: [
                    TextSpan(
                      text: 'Equilibrium',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(color: MindfulColors.clayAccent, fontSize: 42),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 42),
              ),
              const SizedBox(height: 20),
              Row(
                children: const [
                  _RangeChip(label: '6 MONTHS', selected: true),
                  SizedBox(width: 8),
                  _RangeChip(label: '1 YEAR'),
                  SizedBox(width: 8),
                  _RangeChip(label: 'ALL TIME'),
                ],
              ),
              const SizedBox(height: 22),
              TonalCard(
                color: MindfulColors.surfaceContainerLowest,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Overall Balance Score', style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('$overall', style: Theme.of(context).textTheme.displayLarge),
                        const SizedBox(width: 12),
                        const Icon(Icons.trending_up_rounded, color: MindfulColors.clayAccent),
                        const SizedBox(width: 4),
                        Text('+4.2%', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: MindfulColors.clayAccent)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your balance has reached a new peak this quarter, driven by improvements in Mind and Health.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MindfulColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 20),
                    TrendLineChart(points: trendPoints),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              TonalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Life Dimensions', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 14),
                    DimensionBars(scores: state.dimensions),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              TonalCard(
                color: MindfulColors.surfaceContainerLowest,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Key Insights', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 14),
                    const _InsightBlock(
                      icon: Icons.trending_up_rounded,
                      title: 'Strengths',
                      body:
                          'Your Health-Social correlation is improving. Shared workouts or active social time can compound both dimensions simultaneously.',
                    ),
                    const SizedBox(height: 14),
                    const _InsightBlock(
                      icon: Icons.warning_rounded,
                      title: 'Growth Areas',
                      body:
                          'Financial stress is beginning to impact Mind resilience. Review the Advice tab and add one lightweight budgeting action.',
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
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? MindfulColors.inkBlack : MindfulColors.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: selected ? Colors.white : MindfulColors.onSurfaceVariant,
            ),
      ),
    );
  }
}

class _InsightBlock extends StatelessWidget {
  const _InsightBlock({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: MindfulColors.clayAccent),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 4),
              Text(body, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
