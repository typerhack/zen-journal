import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../../core/theme/theme.dart';

/// Multi-line text input built on [EditableText] — not TextField.
/// No Material decoration, no underline, no floating label.
/// The cursor and selection use ZenTheme accent colour.
class ZenTextInput extends StatefulWidget {
  const ZenTextInput({
    super.key,
    required this.controller,
    this.focusNode,
    this.placeholder,
    this.onChanged,
    this.minLines = 1,
    this.maxLines,
    this.textStyle,
    this.semanticLabel,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final int minLines;
  final int? maxLines;
  final TextStyle? textStyle;
  final String? semanticLabel;

  @override
  State<ZenTextInput> createState() => _ZenTextInputState();
}

class _ZenTextInputState extends State<ZenTextInput> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.zenTheme;
    final style = widget.textStyle ?? theme.text.bodyLarge;

    return Semantics(
      label: widget.semanticLabel ?? widget.placeholder,
      textField: true,
      multiline: (widget.maxLines ?? 2) > 1,
      child: Stack(
        children: [
          // Placeholder text — shown when controller is empty
          if (widget.placeholder != null)
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: widget.controller,
              builder: (context, value, _) {
                if (value.text.isNotEmpty) return const SizedBox.shrink();
                return Text(
                  widget.placeholder!,
                  style: style.copyWith(color: theme.colors.onSurfaceFaint),
                );
              },
            ),
          EditableText(
            controller: widget.controller,
            focusNode: _focusNode,
            style: style,
            cursorColor: theme.colors.accent,
            backgroundCursorColor: theme.colors.surfaceElevated,
            selectionColor: theme.colors.accentFaint,
            strutStyle: StrutStyle(
              fontFamily: style.fontFamily,
              fontSize: style.fontSize,
              height: style.height,
              forceStrutHeight: true,
            ),
            maxLines: widget.maxLines,
            keyboardType: (widget.maxLines ?? 2) > 1
                ? TextInputType.multiline
                : TextInputType.text,
            textInputAction: (widget.maxLines ?? 2) > 1
                ? TextInputAction.newline
                : TextInputAction.done,
            onChanged: widget.onChanged,
          ),
        ],
      ),
    );
  }
}
