import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';
import '../../../core/router/app_router.dart';
import '../../../ui/components/zen_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.zenTheme;
    return ColoredBox(
      color: theme.colors.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ZenSpacing.pageMarginMobile,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                'zen journal',
                style: theme.text.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ZenSpacing.s16),
              Text(
                'A quiet place to meet yourself.',
                style: theme.text.bodyMedium.copyWith(
                  color: theme.colors.onSurfaceMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              ZenButton(
                label: 'begin',
                onTap: () => context.go(Routes.onboardingTheme),
              ),
              const SizedBox(height: ZenSpacing.s48),
            ],
          ),
        ),
      ),
    );
  }
}
