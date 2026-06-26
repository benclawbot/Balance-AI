import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';

class BalanceShell extends StatelessWidget {
  const BalanceShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final index = switch (location) {
      String path when path.startsWith('/wheel') => 1,
      String path when path.startsWith('/advice') => 2,
      String path when path.startsWith('/growth') => 3,
      String path when path.startsWith('/report') => 3,
      _ => 0,
    };

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: child,
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: NavigationBar(
            selectedIndex: index,
            height: 72,
            onDestinationSelected: (selected) {
              final route = switch (selected) {
                0 => '/assess',
                1 => '/wheel',
                2 => '/advice',
                3 => '/growth',
                _ => '/assess',
              };
              context.go(route);
            },
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.mic_rounded), label: 'Assess'),
              NavigationDestination(
                  icon: Icon(Icons.pie_chart_rounded), label: 'Wheel'),
              NavigationDestination(
                  icon: Icon(Icons.lightbulb_rounded), label: 'Advice'),
              NavigationDestination(
                  icon: Icon(Icons.trending_up_rounded), label: 'Growth'),
            ],
          ),
        ),
      ),
    );
  }
}

class BalanceTopBar extends StatelessWidget {
  const BalanceTopBar({super.key, this.title = 'Balance AI'});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bannerHeight = (constraints.maxWidth * 0.23).clamp(94.0, 128.0);
          return Semantics(
            image: true,
            label: title == 'Balance AI'
                ? 'Balance AI hero banner'
                : 'Balance AI $title hero banner',
            child: Container(
              height: bannerHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: MindfulColors.inkBlack.withValues(alpha: 0.06),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  'assets/images/balance_ai_hero_banner.png',
                  width: double.infinity,
                  height: bannerHeight,
                  fit: BoxFit.cover,
                  alignment: Alignment.centerLeft,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ScreenScroll extends StatelessWidget {
  const ScreenScroll({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 108),
      children: children,
    );
  }
}

class SectionEyebrow extends StatelessWidget {
  const SectionEyebrow(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: MindfulColors.clayAccent,
            fontWeight: FontWeight.w800,
          ),
    );
  }
}

class TonalCard extends StatelessWidget {
  const TonalCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? MindfulColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: MindfulColors.inkBlack.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: MindfulColors.inkBlack.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}
