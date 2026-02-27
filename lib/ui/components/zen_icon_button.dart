import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/theme.dart';

/// Icon-based action element.
/// Touch target is always 48×48px regardless of icon size.
/// Requires a semantic label — never a silent tap target.
class ZenIconButton extends StatefulWidget {
  const ZenIconButton({
    super.key,
    required this.assetPath,
    required this.semanticLabel,
    required this.onTap,
    this.iconSize = 20,
    this.isDisabled = false,
    this.color,
  });

  final String assetPath;
  final String semanticLabel;
  final VoidCallback onTap;
  final double iconSize;
  final bool isDisabled;

  /// Override icon color — defaults to [ZenColors.onSurface]
  final Color? color;

  @override
  State<ZenIconButton> createState() => _ZenIconButtonState();
}

class _ZenIconButtonState extends State<ZenIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.zenTheme;
    final reduce = ZenThemeData.reduceMotion(context);
    final iconColor = widget.isDisabled
        ? theme.colors.onSurfaceFaint
        : widget.color ?? theme.colors.onSurface;

    return Semantics(
      label: widget.semanticLabel,
      button: true,
      enabled: !widget.isDisabled,
      child: GestureDetector(
        onTapDown: (_) {
          if (!widget.isDisabled) setState(() => _pressed = true);
        },
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.isDisabled ? null : widget.onTap,
        child: AnimatedOpacity(
          opacity: widget.isDisabled
              ? 0.4
              : _pressed
                  ? 0.5
                  : 1.0,
          duration: reduce ? Duration.zero : ZenSpacing.fast,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: SvgPicture.asset(
                widget.assetPath,
                width: widget.iconSize,
                height: widget.iconSize,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
