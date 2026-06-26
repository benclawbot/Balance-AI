import 'package:go_router/go_router.dart';

import '../ui/components/app_chrome.dart';
import '../ui/screens/advice_screen.dart';
import '../ui/screens/assessment_screen.dart';
import '../ui/screens/growth_screen.dart';
import '../ui/screens/report_screen.dart';
import '../ui/screens/wheel_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/assess',
  routes: [
    ShellRoute(
      builder: (context, state, child) => BalanceShell(child: child),
      routes: [
        GoRoute(path: '/assess', builder: (context, state) => const AssessmentScreen()),
        GoRoute(path: '/wheel', builder: (context, state) => const WheelScreen()),
        GoRoute(path: '/advice', builder: (context, state) => const AdviceScreen()),
        GoRoute(path: '/growth', builder: (context, state) => const GrowthScreen()),
        GoRoute(path: '/report', builder: (context, state) => const ReportScreen()),
      ],
    ),
  ],
);
