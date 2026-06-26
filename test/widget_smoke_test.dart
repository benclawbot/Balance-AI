import 'package:balance_ai/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('Balance AI renders the assessment screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: BalanceAiApp()));
    await tester.pumpAndSettle();

    expect(
        find.image(
            const AssetImage('assets/images/balance_ai_hero_banner.png')),
        findsOneWidget);
    expect(find.textContaining('Currently Assessing'), findsOneWidget);
    expect(find.text('Assess'), findsOneWidget);
    expect(find.text('Wheel'), findsOneWidget);
    expect(find.text('Advice'), findsOneWidget);
    expect(find.text('Growth'), findsWidgets);
  });
}
