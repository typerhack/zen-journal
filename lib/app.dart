import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/theme.dart';
import 'core/router/app_router.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
    // Resolve system brightness
    final brightness = View.of(context).platformDispatcher.platformBrightness;
    final themeData = ZenThemeData.fromBrightness(brightness);

    return ZenTheme(
      data: themeData,
      child: WidgetsApp.router(
        title: 'zen journal',
        color: themeData.colors.accent,
        routerConfig: appRouter,
        builder: (context, child) => ColoredBox(
          color: themeData.colors.surface,
          // Stack lives inside WidgetsApp so Directionality is already provided
          child: Stack(
            children: [
              child ?? const SizedBox.shrink(),
              // Background obscure layer — hides content in app switcher
              if (_obscured)
                Positioned.fill(child: _ObscureLayer(colors: themeData.colors)),
            ],
          ),
        ),
      ),
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
