import 'package:flutter/widgets.dart';
import 'zen_colors.dart';
import 'zen_text.dart';
import 'zen_spacing.dart';

/// The single source of truth for all design tokens in Zen Journal.
///
/// Access via [ZenTheme.of(context)]. Never use Theme.of(context) or
/// any Material/Cupertino theme.
///
/// Usage:
/// ```dart
/// final theme = ZenTheme.of(context);
/// Container(color: theme.colors.surface)
/// Text('hello', style: theme.text.bodyLarge)
/// SizedBox(height: theme.spacing.s16)
/// ```
class ZenTheme extends InheritedWidget {
  const ZenTheme({super.key, required this.data, required super.child});

  final ZenThemeData data;

  static ZenThemeData of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<ZenTheme>();
    assert(theme != null, 'No ZenTheme found in widget tree');
    return theme!.data;
  }

  @override
  bool updateShouldNotify(ZenTheme oldWidget) => data != oldWidget.data;
}

/// Immutable snapshot of all design tokens for one theme variant.
class ZenThemeData {
  const ZenThemeData({
    required this.brightness,
    required this.colors,
    required this.text,
  });

  final Brightness brightness;
  final ZenColors colors;
  final ZenTextStyles text;

  // Spacing and animation tokens are constants — same across themes
  ZenSpacing get spacing => const ZenSpacing();

  bool get isDark => brightness == Brightness.dark;

  /// Whether the system has requested reduced motion.
  /// Pass [context] to read MediaQuery.
  static bool reduceMotion(BuildContext context) =>
      MediaQuery.of(context).disableAnimations;

  // ── Named constructors ─────────────────────────────────────────────────────

  factory ZenThemeData.zen() => ZenThemeData(
    brightness: Brightness.light,
    colors: ZenColors.light,
    text: ZenTextStyles.forColor(ZenColors.light.onSurface),
  );

  factory ZenThemeData.dark() => ZenThemeData(
    brightness: Brightness.dark,
    colors: ZenColors.dark,
    text: ZenTextStyles.forColor(ZenColors.dark.onSurface),
  );

  factory ZenThemeData.fromBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? ZenThemeData.dark() : ZenThemeData.zen();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZenThemeData &&
          runtimeType == other.runtimeType &&
          brightness == other.brightness;

  @override
  int get hashCode => brightness.hashCode;
}

/// Convenience extension so widgets can write [context.zenTheme]
/// instead of [ZenTheme.of(context)].
extension ZenThemeContext on BuildContext {
  ZenThemeData get zenTheme => ZenTheme.of(this);
}
