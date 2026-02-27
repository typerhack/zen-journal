import 'package:go_router/go_router.dart';

import '../../features/onboarding/ui/welcome_page.dart';
import '../../features/onboarding/ui/theme_setup_page.dart';
import '../../features/onboarding/ui/sync_setup_page.dart';
import '../../features/onboarding/ui/first_entry_page.dart';
import '../../features/journal/ui/journal_page.dart';
import '../../features/settings/ui/settings_page.dart';

abstract class Routes {
  static const onboardingWelcome = '/onboarding/welcome';
  static const onboardingTheme = '/onboarding/theme';
  static const onboardingSync = '/onboarding/sync';
  static const onboardingFirstEntry = '/onboarding/first-entry';
  static const journal = '/journal';
  static const settings = '/settings';
}

GoRouter createAppRouter({required bool onboardingComplete}) {
  return GoRouter(
    initialLocation: onboardingComplete
        ? Routes.journal
        : Routes.onboardingWelcome,
    redirect: (context, state) {
      final inOnboarding = state.matchedLocation.startsWith('/onboarding');
      if (!onboardingComplete && !inOnboarding) {
        return Routes.onboardingWelcome;
      }
      if (onboardingComplete && inOnboarding) {
        return Routes.journal;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.onboardingWelcome,
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: Routes.onboardingTheme,
        builder: (context, state) => const ThemeSetupPage(),
      ),
      GoRoute(
        path: Routes.onboardingSync,
        builder: (context, state) => const SyncSetupPage(),
      ),
      GoRoute(
        path: Routes.onboardingFirstEntry,
        builder: (context, state) => const FirstEntryPage(),
      ),
      GoRoute(
        path: Routes.journal,
        builder: (context, state) => const JournalPage(),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
}
