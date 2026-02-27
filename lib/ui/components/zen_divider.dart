import 'package:flutter/widgets.dart';
import '../../core/theme/theme.dart';

/// Subtle 1px horizontal divider using [ZenColors.onSurfaceFaint].
class ZenDivider extends StatelessWidget {
  const ZenDivider({super.key, this.indent = 0});

  final double indent;

  @override
  Widget build(BuildContext context) {
    final theme = context.zenTheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ZenSpacing.s16),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: indent),
        height: 1,
        color: theme.colors.onSurfaceFaint,
      ),
    );
  }
}
