import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router.dart';
import 'app/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: BalanceAiApp()));
}

class BalanceAiApp extends StatelessWidget {
  const BalanceAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Balance AI',
      debugShowCheckedModeBanner: false,
      theme: MindfulTheme.light(),
      routerConfig: appRouter,
    );
  }
}
