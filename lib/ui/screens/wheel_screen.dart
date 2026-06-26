import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../domain/life_dimension.dart';
import '../../domain/scoring.dart';
import '../../state/balance_controller.dart';
import '../components/app_chrome.dart';
import '../components/life_wheel.dart';

class WheelScreen extends ConsumerWidget {
  const WheelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(balanceControllerProvider);
    final controller = ref.read(balanceControllerProvider.notifier);
    final scoringEngine = const BalanceScoringEngine();
    final selectedScore = state.dimensions[state.selectedDimension];
    final overall = scoringEngine.overallScore(state.dimensions);
    final focus = scoringEngine
        .priorityDimensions(state.dimensions, limit: 1)
        .first
        .type
        .label;

    return Column(
      children: [
        const BalanceTopBar(),
        Expanded(
          child: ScreenScroll(
            children: [
              const SectionEyebrow('Holistic Audit'),
              const SizedBox(height: 8),
              Text('Your Life Wheel',
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(fontSize: 44)),
              const SizedBox(height: 10),
              Text(
                'Visualize your current balance across 8 key dimensions. Tap a segment or adjust the slider to reflect your reality.',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: MindfulColors.onSurfaceVariant),
              ),
              const SizedBox(height: 28),
              TonalCard(
                color: MindfulColors.surfaceContainerLowest,
                padding: const EdgeInsets.all(18),
                child: LifeWheel(
                  scores: state.dimensions,
                  selectedDimension: state.selectedDimension,
                  onDimensionSelected: controller.selectDimension,
                ),
              ),
              const SizedBox(height: 22),
              TonalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(state.selectedDimension.icon,
                            color: MindfulColors.clayAccent),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            selectedScore?.type.label ?? 'Dimension',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Text(
                            '${selectedScore?.score.toStringAsFixed(1) ?? '0'}/10',
                            style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text('CURRENT LEVEL:',
                        style: Theme.of(context).textTheme.labelSmall),
                    Slider(
                      min: 1,
                      max: 10,
                      divisions: 18,
                      value: selectedScore?.score ?? 5,
                      onChanged: (value) => controller.updateScore(
                          state.selectedDimension, value),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '“${selectedScore?.note ?? ''}”',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: MindfulColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricPill(
                            icon: Icons.star_rounded,
                            label: 'Priority',
                            value: focus,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MetricPill(
                            icon: Icons.trending_up_rounded,
                            label: 'Total',
                            value: overall.toStringAsFixed(1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: state.isGeneratingAdvice
                    ? null
                    : () async {
                        final generated = await controller.generateAiAdvice();
                        if (context.mounted && generated) context.go('/advice');
                      },
                icon: state.isGeneratingAdvice
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.lightbulb_rounded),
                label: Text(state.isGeneratingAdvice
                    ? 'GENERATING...'
                    : 'GET AI ADVICE'),
              ),
              if (state.lastError != null) ...[
                const SizedBox(height: 12),
                Text(state.lastError!,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: MindfulColors.clayAccent)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill(
      {required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MindfulColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: MindfulColors.clayAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall),
                Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
