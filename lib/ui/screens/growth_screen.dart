import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../domain/scoring.dart';
import '../../state/balance_controller.dart';
import '../components/app_chrome.dart';

class GrowthScreen extends ConsumerWidget {
  const GrowthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(balanceControllerProvider);
    final controller = ref.read(balanceControllerProvider.notifier);
    final completion =
        const BalanceScoringEngine().completionRatio(state.actions);
    final completedCount = state.actions.where((item) => item.completed).length;
    final pendingCount = state.actions.length - completedCount;

    return Column(
      children: [
        const BalanceTopBar(),
        Expanded(
          child: ScreenScroll(
            children: [
              const SectionEyebrow('Current Milestone'),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                      child: Text('Growth Phase',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(fontSize: 44))),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${(completion * 100).round()}%',
                          style: Theme.of(context).textTheme.headlineMedium),
                      Text('COMPLETED',
                          style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              LinearProgressIndicator(
                value: completion,
                minHeight: 10,
                borderRadius: BorderRadius.circular(999),
                backgroundColor: MindfulColors.surfaceContainerHigh,
                valueColor:
                    const AlwaysStoppedAnimation(MindfulColors.clayAccent),
              ),
              const SizedBox(height: 18),
              TonalCard(
                child: Row(
                  children: [
                    const Icon(Icons.checklist_rounded,
                        color: MindfulColors.clayAccent),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text('Actionable Steps',
                            style: Theme.of(context).textTheme.titleMedium)),
                    Text('$pendingCount',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(width: 6),
                    Text('PENDING',
                        style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text('Today\'s Focus',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                proxyDecorator: (child, index, animation) {
                  return Material(
                    color: Colors.transparent,
                    child: ScaleTransition(
                      scale:
                          Tween<double>(begin: 1, end: 1.02).animate(animation),
                      child: child,
                    ),
                  );
                },
                itemCount: state.actions.length,
                onReorderItem: controller.reorderAction,
                itemBuilder: (context, index) {
                  final item = state.actions[index];
                  return Padding(
                    key: ValueKey(item.id),
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TonalCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      color: item.completed
                          ? MindfulColors.surfaceContainerHigh
                          : MindfulColors.surfaceContainerLowest,
                      child: Row(
                        children: [
                          Checkbox(
                            value: item.completed,
                            activeColor: MindfulColors.clayAccent,
                            onChanged: (_) => controller.toggleAction(item.id),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        decoration: item.completed
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(item.category,
                                    style:
                                        Theme.of(context).textTheme.labelSmall),
                              ],
                            ),
                          ),
                          ReorderableDragStartListener(
                            index: index,
                            child: const Icon(Icons.drag_indicator_rounded,
                                color: MindfulColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              TonalCard(
                color: MindfulColors.inkBlack,
                child: Row(
                  children: [
                    const Icon(Icons.description_rounded, color: Colors.white),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Generate Full Report',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: Colors.white)),
                          const SizedBox(height: 6),
                          Text(
                            'Detailed report includes dimension synthesis and weekly trend analysis.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.7)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.go('/report'),
                      icon: const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Center(
                child: Text('Stay in the flow.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: MindfulColors.onSurfaceVariant)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
