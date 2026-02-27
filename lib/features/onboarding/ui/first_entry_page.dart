import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:record/record.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/theme.dart';
import '../../../ui/components/zen_button.dart';
import '../../../ui/components/zen_scaffold.dart';
import '../../../ui/components/zen_text_input.dart';
import '../../journal/data/entry_repository.dart';
import '../data/onboarding_state_store.dart';

class FirstEntryPage extends ConsumerStatefulWidget {
  const FirstEntryPage({super.key});

  @override
  ConsumerState<FirstEntryPage> createState() => _FirstEntryPageState();
}

class _FirstEntryPageState extends ConsumerState<FirstEntryPage> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final AudioRecorder _audioRecorder;
  bool _showMicPermissionPrompt = false;
  String? _micStatusMessage;
  bool _micStatusFailed = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _audioRecorder = AudioRecorder();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    unawaited(_audioRecorder.dispose());
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    final entryText = _controller.text.trim();
    if (entryText.isEmpty) return;
    await ref
        .read(journalEntriesProvider.notifier)
        .createEntry(
          body: entryText,
          prompt: 'What are you carrying into this moment?',
        );
    await ref
        .read(onboardingControllerProvider.notifier)
        .saveFirstEntry(entryText);
    await ref.read(onboardingControllerProvider.notifier).completeOnboarding();
    if (!mounted) return;
    context.go(Routes.journal);
  }

  Future<void> _requestMicrophonePermission() async {
    final granted = await _audioRecorder.hasPermission(request: true);
    if (!mounted) return;
    setState(() {
      _showMicPermissionPrompt = false;
      _micStatusMessage = granted
          ? '[ok] microphone enabled'
          : '[failed] microphone permission not granted';
      _micStatusFailed = !granted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.zenTheme;
    final dateLabel = DateFormat('EEEE, MMM d').format(DateTime.now());

    return ZenScaffold(
      padding: const EdgeInsets.fromLTRB(
        ZenSpacing.pageMarginMobile,
        ZenSpacing.s24,
        ZenSpacing.pageMarginMobile,
        ZenSpacing.s24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today, $dateLabel',
            style: theme.text.bodySmall.copyWith(
              color: theme.colors.onSurfaceMuted,
            ),
          ),
          const SizedBox(height: ZenSpacing.s24),
          Text(
            'What are you carrying\ninto this moment?',
            style: theme.text.displaySmall,
          ),
          const SizedBox(height: ZenSpacing.s24),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(ZenSpacing.s16),
              decoration: BoxDecoration(
                color: theme.colors.surfaceElevated,
                borderRadius: BorderRadius.circular(ZenSpacing.radiusMedium),
              ),
              child: ZenTextInput(
                controller: _controller,
                focusNode: _focusNode,
                minLines: 8,
                maxLines: null,
                placeholder: 'Write here...',
                semanticLabel: 'First journal entry',
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          const SizedBox(height: ZenSpacing.s16),
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _MicIconButton(
                    onTap: () {
                      setState(() {
                        _showMicPermissionPrompt = true;
                        _micStatusMessage = null;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: ZenSpacing.s12),
              ZenButton(
                label: 'save',
                isDisabled: _controller.text.trim().isEmpty,
                onTap: _saveAndContinue,
              ),
            ],
          ),
          if (_showMicPermissionPrompt) ...[
            const SizedBox(height: ZenSpacing.s12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(ZenSpacing.s12),
              decoration: BoxDecoration(
                color: theme.colors.surfaceElevated,
                borderRadius: BorderRadius.circular(ZenSpacing.radiusMedium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Zen Journal would like to use your microphone to transcribe your voice into text.',
                    style: theme.text.bodySmall,
                  ),
                  const SizedBox(height: ZenSpacing.s8),
                  Text(
                    'Your audio is processed on this device and never uploaded.',
                    style: theme.text.bodySmall.copyWith(
                      color: theme.colors.onSurfaceMuted,
                    ),
                  ),
                  const SizedBox(height: ZenSpacing.s12),
                  ZenButton(
                    label: 'allow microphone',
                    isFullWidth: true,
                    onTap: _requestMicrophonePermission,
                  ),
                ],
              ),
            ),
          ],
          if (_micStatusMessage != null) ...[
            const SizedBox(height: ZenSpacing.s12),
            Text(
              _micStatusMessage!,
              style: theme.text.bodySmall.copyWith(
                color: _micStatusFailed
                    ? theme.colors.destructive
                    : theme.colors.onSurfaceMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MicIconButton extends StatefulWidget {
  const _MicIconButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_MicIconButton> createState() => _MicIconButtonState();
}

class _MicIconButtonState extends State<_MicIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.zenTheme;
    return Semantics(
      label: 'Try voice input',
      button: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: ZenSpacing.fast,
          curve: ZenSpacing.easeDefault,
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _pressed
                ? theme.colors.surfaceSunken
                : theme.colors.surfaceElevated,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CustomPaint(
                painter: _MicPainter(color: theme.colors.onSurface),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MicPainter extends CustomPainter {
  const _MicPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.34,
        size.height * 0.16,
        size.width * 0.32,
        size.height * 0.48,
      ),
      Radius.circular(size.width * 0.16),
    );
    canvas.drawRRect(bodyRect, stroke);

    final stemStart = Offset(size.width * 0.5, size.height * 0.64);
    final stemEnd = Offset(size.width * 0.5, size.height * 0.80);
    canvas.drawLine(stemStart, stemEnd, stroke);

    final baseStart = Offset(size.width * 0.35, size.height * 0.84);
    final baseEnd = Offset(size.width * 0.65, size.height * 0.84);
    canvas.drawLine(baseStart, baseEnd, stroke);

    final arcRect = Rect.fromLTWH(
      size.width * 0.22,
      size.height * 0.40,
      size.width * 0.56,
      size.height * 0.36,
    );
    canvas.drawArc(arcRect, 0.0, 3.14159, false, stroke);
  }

  @override
  bool shouldRepaint(covariant _MicPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
