import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/theme.dart';
import 'core/router/app_router.dart';
import 'features/onboarding/data/onboarding_state_store.dart';

/// Root of the application.
/// Handles system theme detection, lifecycle observation for background
/// blur, and ZenTheme injection.
class ZenJournalApp extends ConsumerStatefulWidget {
  const ZenJournalApp({super.key});

  @override
  ConsumerState<ZenJournalApp> createState() => _ZenJournalAppState();
}

class _ZenJournalAppState extends ConsumerState<ZenJournalApp>
    with WidgetsBindingObserver {
  bool _obscured = false;
  GoRouter? _router;
  bool? _routerOnboardingComplete;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _router?.dispose();
    super.dispose();
  }

  GoRouter _resolveRouter(bool onboardingComplete) {
    if (_router == null || _routerOnboardingComplete != onboardingComplete) {
      _router?.dispose();
      _router = createAppRouter(onboardingComplete: onboardingComplete);
      _routerOnboardingComplete = onboardingComplete;
    }
    return _router!;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final shouldObscure =
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused;
    if (shouldObscure != _obscured) {
      setState(() => _obscured = shouldObscure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingControllerProvider);

    final systemBrightness = View.of(
      context,
    ).platformDispatcher.platformBrightness;

    return onboardingState.when(
      loading: () {
        final themeData = ZenThemeData.fromBrightness(systemBrightness);
        return ZenTheme(
          data: themeData,
          child: WidgetsApp(
            title: 'zen journal',
            color: themeData.colors.accent,
            builder: (context, child) => Center(
              child: Text(
                'loading...',
                style: themeData.text.bodyMedium.copyWith(
                  color: themeData.colors.onSurfaceMuted,
                ),
              ),
            ),
          ),
        );
      },
      error: (error, stack) {
        final themeData = ZenThemeData.fromBrightness(systemBrightness);
        return ZenTheme(
          data: themeData,
          child: WidgetsApp(
            title: 'zen journal',
            color: themeData.colors.accent,
            builder: (context, child) => Center(
              child: Text(
                '[failed] unable to load onboarding state',
                style: themeData.text.bodyMedium.copyWith(
                  color: themeData.colors.destructive,
                ),
              ),
            ),
          ),
        );
      },
      data: (onboarding) {
        final brightness = switch (onboarding.themePreference) {
          AppThemePreference.system => systemBrightness,
          AppThemePreference.light => Brightness.light,
          AppThemePreference.dark => Brightness.dark,
        };
        final themeData = ZenThemeData.fromBrightness(brightness);
        return ZenTheme(
          data: themeData,
          child: WidgetsApp.router(
            title: 'zen journal',
            color: themeData.colors.accent,
            routerConfig: _resolveRouter(onboarding.isComplete),
            builder: (context, child) => ColoredBox(
              color: themeData.colors.surface,
              // Stack lives inside WidgetsApp so Directionality is already provided
              child: Stack(
                children: [
                  child ?? const SizedBox.shrink(),
                  // Background obscure layer — hides content in app switcher
                  if (_obscured)
                    Positioned.fill(
                      child: _ObscureLayer(colors: themeData.colors),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ObscureLayer extends StatelessWidget {
  const _ObscureLayer({required this.colors});
  final ZenColors colors;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: colors.surface,
      child: Center(
        child: Text(
          'zen journal',
          style: ZenTextStyles.forColor(colors.onSurfaceMuted).displaySmall,
        ),
      ),
    );
  }
}
