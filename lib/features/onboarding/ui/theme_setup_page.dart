import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/theme.dart';
import '../../../ui/components/zen_button.dart';
import '../../../ui/components/zen_scaffold.dart';
import '../data/onboarding_state_store.dart';

class ThemeSetupPage extends ConsumerWidget {
  const ThemeSetupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.zenTheme;

    Future<void> selectTheme(AppThemePreference preference) async {
      await ref
          .read(onboardingControllerProvider.notifier)
          .setThemePreference(preference);
      if (!context.mounted) return;
      context.go(Routes.onboardingSync);
    }

    return ZenScaffold(
      padding: const EdgeInsets.symmetric(
        horizontal: ZenSpacing.pageMarginMobile,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Choose your space',
            style: theme.text.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ZenSpacing.s16),
          Text(
            'Follow your system setting,\nor pick one now.',
            style: theme.text.bodyMedium.copyWith(
              color: theme.colors.onSurfaceMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ZenSpacing.s48),
          ZenButton(
            label: 'use system theme',
            isFullWidth: true,
            onTap: () => selectTheme(AppThemePreference.system),
          ),
          const SizedBox(height: ZenSpacing.s12),
          ZenButton(
            label: 'zen light',
            isFullWidth: true,
            onTap: () => selectTheme(AppThemePreference.light),
          ),
          const SizedBox(height: ZenSpacing.s12),
          ZenButton(
            label: 'dark',
            isFullWidth: true,
            onTap: () => selectTheme(AppThemePreference.dark),
          ),
        ],
      ),
    );
  }
}
