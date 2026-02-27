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
                  child: ZenButton(
                    label: 'try voice',
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
