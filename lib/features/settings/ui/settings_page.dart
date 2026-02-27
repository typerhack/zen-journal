// Settings — a calm, focused page for managing user preferences.
// One concern per section. No nested menus, no heavy chrome.
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../ui/components/zen_divider.dart';
import '../../../ui/components/zen_scaffold.dart';
import '../../onboarding/data/onboarding_state_store.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.zenTheme;
    final state = ref.watch(onboardingControllerProvider);

    return ZenScaffold(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          ZenSpacing.pageMarginMobile,
          ZenSpacing.s24,
          ZenSpacing.pageMarginMobile,
          ZenSpacing.s24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BackButton(),
            const SizedBox(height: ZenSpacing.s32),
            Text('Settings', style: theme.text.displaySmall),
            const SizedBox(height: ZenSpacing.s48),
            // ── Appearance ─────────────────────────────────────────────────
            Text(
              'Appearance',
              style: theme.text.bodySmall.copyWith(
                color: theme.colors.onSurfaceMuted,
                letterSpacing: 0.5,
              ),
            ),
            const ZenDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Theme', style: theme.text.bodyMedium),
                state.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (s) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ThemeChip(
                        label: 'system',
                        isSelected:
                            s.themePreference == AppThemePreference.system,
                        onTap: () => ref
                            .read(onboardingControllerProvider.notifier)
                            .setThemePreference(AppThemePreference.system),
                      ),
                      const SizedBox(width: ZenSpacing.s8),
                      _ThemeChip(
                        label: 'zen',
                        isSelected:
                            s.themePreference == AppThemePreference.light,
                        onTap: () => ref
                            .read(onboardingControllerProvider.notifier)
                            .setThemePreference(AppThemePreference.light),
                      ),
                      const SizedBox(width: ZenSpacing.s8),
                      _ThemeChip(
                        label: 'dark',
                        isSelected:
                            s.themePreference == AppThemePreference.dark,
                        onTap: () => ref
                            .read(onboardingControllerProvider.notifier)
                            .setThemePreference(AppThemePreference.dark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatefulWidget {
  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.zenTheme;
    final reduce = ZenThemeData.reduceMotion(context);
    return Semantics(
      label: 'Back',
      button: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () => context.pop(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CustomPaint(
                painter: _ChevronLeftPainter(
                  color: _pressed
                      ? theme.colors.onSurfaceFaint
                      : theme.colors.onSurfaceMuted,
                ),
              ),
            ),
            const SizedBox(width: ZenSpacing.s8),
            AnimatedDefaultTextStyle(
              duration: reduce ? Duration.zero : ZenSpacing.fast,
              curve: ZenSpacing.easeDefault,
              style: theme.text.bodySmall.copyWith(
                color: _pressed
                    ? theme.colors.onSurfaceFaint
                    : theme.colors.onSurfaceMuted,
              ),
              child: const Text('back'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeChip extends StatefulWidget {
  const _ThemeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_ThemeChip> createState() => _ThemeChipState();
}

class _ThemeChipState extends State<_ThemeChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.zenTheme;
    final reduce = ZenThemeData.reduceMotion(context);
    final bgColor = (widget.isSelected || _pressed)
        ? theme.colors.surfaceSunken
        : theme.colors.surfaceElevated;
    final textColor = widget.isSelected
        ? theme.colors.accent
        : theme.colors.onSurface;

    return Semantics(
      label: widget.label,
      button: true,
      selected: widget.isSelected,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: reduce ? Duration.zero : ZenSpacing.fast,
          curve: ZenSpacing.easeDefault,
          constraints: const BoxConstraints(minWidth: 52, minHeight: 36),
          padding: const EdgeInsets.symmetric(
            horizontal: ZenSpacing.s12,
            vertical: ZenSpacing.s8,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(ZenSpacing.radiusMedium),
          ),
          child: AnimatedDefaultTextStyle(
            duration: reduce ? Duration.zero : ZenSpacing.fast,
            curve: ZenSpacing.easeDefault,
            style: theme.text.labelMedium.copyWith(color: textColor),
            child: Text(widget.label, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}

class _ChevronLeftPainter extends CustomPainter {
  const _ChevronLeftPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.62, size.height * 0.20)
      ..lineTo(size.width * 0.34, size.height * 0.50)
      ..lineTo(size.width * 0.62, size.height * 0.80);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _ChevronLeftPainter old) => old.color != color;
}
