import 'package:go_router/go_router.dart';

import '../../features/onboarding/ui/welcome_page.dart';
import '../../features/journal/ui/journal_page.dart';

abstract class Routes {
  static const onboarding = '/onboarding';
  static const journal = '/journal';
}

final appRouter = GoRouter(
  initialLocation: Routes.onboarding,
  routes: [
    GoRoute(
      path: Routes.onboarding,
      builder: (context, state) => const WelcomePage(),
    ),
    GoRoute(
      path: Routes.journal,
      builder: (context, state) => const JournalPage(),
    ),
  ],
);
