import 'package:flutter/widgets.dart';
import '../../core/theme/theme.dart';

/// Minimal touch-responsive action element.
/// Conveys state through surface shift and opacity — no borders, no shadows.
/// Supports default, hovered, pressed, and disabled states.
class ZenButton extends StatefulWidget {
  const ZenButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.isDisabled = false,
    this.isFullWidth = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isDisabled;
  final bool isFullWidth;

  @override
  State<ZenButton> createState() => _ZenButtonState();
}

class _ZenButtonState extends State<ZenButton> {
  bool _pressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (!widget.isDisabled) setState(() => _pressed = true);
  }

  void _handleTapUp(TapUpDetails _) => setState(() => _pressed = false);
  void _handleTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    final theme = context.zenTheme;
    final reduce = ZenThemeData.reduceMotion(context);

    final textColor = widget.isDisabled
        ? theme.colors.onSurfaceFaint
        : widget.isDestructive
            ? theme.colors.destructive
            : theme.colors.onSurface;

    final bgColor =
        _pressed ? theme.colors.surfaceSunken : theme.colors.surfaceElevated;

    return Semantics(
      label: widget.label,
      button: true,
      enabled: !widget.isDisabled,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.isDisabled ? null : widget.onTap,
        child: AnimatedOpacity(
          opacity: widget.isDisabled ? 0.4 : 1.0,
          duration: reduce ? Duration.zero : ZenSpacing.fast,
          child: AnimatedContainer(
            duration: reduce ? Duration.zero : ZenSpacing.fast,
            curve: ZenSpacing.easeDefault,
            width: widget.isFullWidth ? double.infinity : null,
            padding: const EdgeInsets.symmetric(
              horizontal: ZenSpacing.s24,
              vertical: ZenSpacing.s12,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(ZenSpacing.radiusMedium),
            ),
            child: Text(
              widget.label,
              style: theme.text.labelMedium.copyWith(color: textColor),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
