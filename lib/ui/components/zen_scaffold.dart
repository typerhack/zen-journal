import 'package:flutter/widgets.dart';
import '../../core/theme/theme.dart';

/// Full-screen surface container — replaces Scaffold.
/// No AppBar, no BottomNavigationBar, no Drawer.
/// Handles safe area and background colour from ZenTheme.
class ZenScaffold extends StatelessWidget {
  const ZenScaffold({
    super.key,
    required this.child,
    this.padding,
    this.safeArea = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    final theme = context.zenTheme;
    Widget body = padding != null
        ? Padding(padding: padding!, child: child)
        : child;
    if (safeArea) body = SafeArea(child: body);
    return ColoredBox(color: theme.colors.surface, child: body);
  }
}
