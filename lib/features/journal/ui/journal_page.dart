import 'dart:io' show Platform;

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme.dart';
import '../../../ui/components/zen_button.dart';
import '../../../ui/components/zen_scaffold.dart';
import '../../../ui/components/zen_text_input.dart';
import '../../onboarding/data/onboarding_state_store.dart';
import '../data/entry_repository.dart';

class JournalPage extends ConsumerStatefulWidget {
  const JournalPage({super.key});

  @override
  ConsumerState<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends ConsumerState<JournalPage>
    with SingleTickerProviderStateMixin {
  static const _reminderOptions = <({String label, int hour, int minute})>[
    (label: '08:00', hour: 8, minute: 0),
    (label: '12:00', hour: 12, minute: 0),
    (label: '18:00', hour: 18, minute: 0),
    (label: '21:00', hour: 21, minute: 0),
  ];

  int _selectedReminderIndex = 0;
  bool _showReminderSetup = false;
  bool _requestingPermission = false;
  String? _reminderStatus;
  bool _reminderStatusFailed = false;

  bool _showComposer = false;
  late final TextEditingController _composerController;
  late final FocusNode _composerFocusNode;
  late final AnimationController _emptyPulseController;
  String? _entryStatus;

  @override
  void initState() {
    super.initState();
    _composerController = TextEditingController();
    _composerFocusNode = FocusNode();
    _emptyPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _composerController.dispose();
    _composerFocusNode.dispose();
    _emptyPulseController.dispose();
    super.dispose();
  }

  void _openComposer() {
    setState(() => _showComposer = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _composerFocusNode.requestFocus();
    });
  }

  Future<void> _saveComposerEntry() async {
    final text = _composerController.text.trim();
    if (text.isEmpty) return;
    try {
      await ref.read(journalEntriesProvider.notifier).createEntry(body: text);
      if (!mounted) return;
      setState(() => _showComposer = false);
      _composerController.clear();
    } catch (e) {
      if (!mounted) return;
      setState(() => _entryStatus = '[failed] Could not save entry');
    }
  }

  String _formatEntryDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDay = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(entryDay).inDays;
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    if (diff == 0) return 'Today, $time';
    if (diff == 1) return 'Yesterday, $time';
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, $time';
  }

  void _onVoiceEntryTap() {
    setState(() {
      _entryStatus = '[pending] Voice entry will be enabled in Phase 6';
    });
  }

  Future<void> _enableReminder() async {
    final option = _reminderOptions[_selectedReminderIndex];
    setState(() {
      _requestingPermission = true;
      _reminderStatus = null;
      _reminderStatusFailed = false;
    });

    bool granted = true;
    try {
      final notifications = FlutterLocalNotificationsPlugin();
      if (Platform.isIOS || Platform.isMacOS) {
        if (Platform.isIOS) {
          granted =
              await notifications
                  .resolvePlatformSpecificImplementation<
                    IOSFlutterLocalNotificationsPlugin
                  >()
                  ?.requestPermissions(alert: true, badge: true, sound: true) ??
              false;
        } else {
          granted =
              await notifications
                  .resolvePlatformSpecificImplementation<
                    MacOSFlutterLocalNotificationsPlugin
                  >()
                  ?.requestPermissions(alert: true, badge: true, sound: true) ??
              false;
        }
      } else if (Platform.isAndroid) {
        granted =
            await notifications
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >()
                ?.requestNotificationsPermission() ??
            true;
      }
    } catch (_) {
      granted = false;
    }

    if (!mounted) return;
    if (granted) {
      await ref
          .read(onboardingControllerProvider.notifier)
          .enableReminder(hour: option.hour, minute: option.minute);
      if (!mounted) return;
      setState(() {
        _requestingPermission = false;
        _showReminderSetup = false;
        _reminderStatus = '[ok] Daily reminder set';
        _reminderStatusFailed = false;
      });
      return;
    }

    setState(() {
      _requestingPermission = false;
      _reminderStatus = '[failed] Notification permission not granted';
      _reminderStatusFailed = true;
    });
  }

  String _formatComposerDate() {
    final now = DateTime.now();
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  Widget _buildFullScreenComposer(ZenThemeData theme) {
    final text = _composerController.text.trim();
    final wordCount = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          ZenSpacing.pageMarginMobile,
          ZenSpacing.s24,
          ZenSpacing.pageMarginMobile,
          ZenSpacing.s16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar — date left, discard right
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _formatComposerDate(),
                  style: theme.text.bodySmall.copyWith(
                    color: theme.colors.onSurfaceMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                _ComposerTextButton(
                  label: 'discard',
                  onTap: () => setState(() {
                    _showComposer = false;
                    _composerController.clear();
                  }),
                ),
              ],
            ),
            const SizedBox(height: ZenSpacing.s48),
            // Full writing surface — no box, no border, no card
            Expanded(
              child: ZenTextInput(
                controller: _composerController,
                focusNode: _composerFocusNode,
                minLines: 1,
                maxLines: null,
                placeholder: 'Begin here...',
                semanticLabel: 'New journal entry',
                textStyle: theme.text.bodyLarge,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: ZenSpacing.s16),
            // Bottom bar — word count left, save right
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedOpacity(
                  opacity: wordCount > 0 ? 1.0 : 0.0,
                  duration: ZenSpacing.normal,
                  child: Text(
                    '$wordCount ${wordCount == 1 ? 'word' : 'words'}',
                    style: theme.text.caption.copyWith(
                      color: theme.colors.onSurfaceFaint,
                    ),
                  ),
                ),
                const Spacer(),
                _ComposerTextButton(
                  label: 'save',
                  isAccent: true,
                  isDisabled: _composerController.text.trim().isEmpty,
                  onTap: _saveComposerEntry,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final theme = context.zenTheme;
    final onboardingState = ref.watch(onboardingControllerProvider);
    final entriesState = ref.watch(journalEntriesProvider);
    final hasEntries = entriesState.maybeWhen(
      data: (entries) => entries.isNotEmpty,
      orElse: () => false,
    );

    return onboardingState.when(
      loading: () => ZenScaffold(
        child: Center(
          child: Text(
            'Loading journal...',
            style: theme.text.bodyMedium.copyWith(
              color: theme.colors.onSurfaceMuted,
            ),
          ),
        ),
      ),
      error: (_, __) => ZenScaffold(
        child: Center(
          child: Text(
            '[failed] Unable to load journal state',
            style: theme.text.bodyMedium.copyWith(
              color: theme.colors.destructive,
            ),
          ),
        ),
      ),
      data: (state) => ZenScaffold(
        child: Padding(
          padding: const EdgeInsets.all(ZenSpacing.pageMarginMobile),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.shouldShowReminderNudge) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(ZenSpacing.s16),
                      decoration: BoxDecoration(
                        color: theme.colors.surfaceElevated,
                        borderRadius: BorderRadius.circular(
                          ZenSpacing.radiusMedium,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'A gentle reminder?',
                            style: theme.text.headingSmall,
                          ),
                          const SizedBox(height: ZenSpacing.s8),
                          Text(
                            'We can nudge you to write each day, at a time you choose.',
                            style: theme.text.bodyMedium.copyWith(
                              color: theme.colors.onSurfaceMuted,
                            ),
                          ),
                          const SizedBox(height: ZenSpacing.s12),
                          Row(
                            children: [
                              Expanded(
                                child: ZenButton(
                                  label: 'set a reminder',
                                  isFullWidth: true,
                                  onTap: () {
                                    setState(() {
                                      _showReminderSetup = true;
                                      _reminderStatus = null;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: ZenSpacing.s12),
                              Expanded(
                                child: ZenButton(
                                  label: 'not for me',
                                  isFullWidth: true,
                                  onTap: () {
                                    ref
                                        .read(
                                          onboardingControllerProvider.notifier,
                                        )
                                        .dismissReminderNudge();
                                  },
                                ),
                              ),
                            ],
                          ),
                          if (_showReminderSetup) ...[
                            const SizedBox(height: ZenSpacing.s12),
                            Text('Choose a time', style: theme.text.bodyMedium),
                            const SizedBox(height: ZenSpacing.s8),
                            Wrap(
                              spacing: ZenSpacing.s8,
                              runSpacing: ZenSpacing.s8,
                              children: List.generate(_reminderOptions.length, (
                                index,
                              ) {
                                final option = _reminderOptions[index];
                                final isSelected =
                                    index == _selectedReminderIndex;
                                return _ReminderChip(
                                  label: option.label,
                                  isSelected: isSelected,
                                  isDisabled: _requestingPermission,
                                  onTap: () => setState(
                                    () => _selectedReminderIndex = index,
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: ZenSpacing.s12),
                            ZenButton(
                              label: _requestingPermission
                                  ? 'requesting permission...'
                                  : 'allow notifications',
                              isFullWidth: true,
                              isDisabled: _requestingPermission,
                              onTap: _enableReminder,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: ZenSpacing.s24),
                  ],
                  if (_reminderStatus != null) ...[
                    Text(
                      _reminderStatus!,
                      style: theme.text.bodySmall.copyWith(
                        color: _reminderStatusFailed
                            ? theme.colors.destructive
                            : theme.colors.onSurfaceMuted,
                      ),
                    ),
                    const SizedBox(height: ZenSpacing.s12),
                  ],
                  Expanded(
                    child: entriesState.when(
                      loading: () => Center(
                        child: Text(
                          'Loading entries...',
                          style: theme.text.bodyMedium.copyWith(
                            color: theme.colors.onSurfaceMuted,
                          ),
                        ),
                      ),
                      error: (_, __) => Center(
                        child: Text(
                          '[failed] Could not load entries',
                          style: theme.text.bodyMedium.copyWith(
                            color: theme.colors.destructive,
                          ),
                        ),
                      ),
                      data: (entries) {
                        if (entries.isEmpty) {
                          final reduceMotion = ZenThemeData.reduceMotion(
                            context,
                          );
                          return Center(
                            child: AnimatedBuilder(
                              animation: _emptyPulseController,
                              builder: (context, _) {
                                final pulse = reduceMotion
                                    ? 0.0
                                    : _emptyPulseController.value;
                                final orbSize = 88.0 + (pulse * 10.0);
                                final haloOne = 140.0 + (pulse * 12.0);
                                final haloTwo = 184.0 + (pulse * 16.0);
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 204,
                                      height: 204,
                                      child: Center(
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Opacity(
                                              opacity: reduceMotion
                                                  ? 0.16
                                                  : 0.06 + (pulse * 0.14),
                                              child: Container(
                                                width: haloTwo,
                                                height: haloTwo,
                                                decoration: BoxDecoration(
                                                  color:
                                                      theme.colors.accentFaint,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                            Opacity(
                                              opacity: reduceMotion
                                                  ? 0.28
                                                  : 0.12 + (pulse * 0.20),
                                              child: Container(
                                                width: haloOne,
                                                height: haloOne,
                                                decoration: BoxDecoration(
                                                  color:
                                                      theme.colors.accentFaint,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: orbSize,
                                              height: orbSize,
                                              decoration: BoxDecoration(
                                                color: theme
                                                    .colors
                                                    .surfaceElevated,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: ZenSpacing.s32),
                                    Text(
                                      'No entries yet',
                                      style: theme.text.headingSmall,
                                    ),
                                    const SizedBox(height: ZenSpacing.s8),
                                    Text(
                                      'Write a line or capture a voice thought.',
                                      style: theme.text.bodyMedium.copyWith(
                                        color: theme.colors.onSurfaceMuted,
                                      ),
                                    ),
                                    const SizedBox(height: ZenSpacing.s24),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _ActionPill(
                                          label: 'new',
                                          semanticLabel: 'Create new entry',
                                          onTap: _openComposer,
                                          icon: _PenPainter(
                                            color: theme.colors.onSurface,
                                          ),
                                        ),
                                        const SizedBox(width: ZenSpacing.s12),
                                        _ActionPill(
                                          label: 'voice',
                                          semanticLabel: 'Start voice entry',
                                          onTap: _onVoiceEntryTap,
                                          icon: _MicPainter(
                                            color: theme.colors.onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.only(
                            bottom: ZenSpacing.s64 + ZenSpacing.s24,
                          ),
                          itemCount: entries.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: ZenSpacing.s12),
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(ZenSpacing.s16),
                              decoration: BoxDecoration(
                                color: theme.colors.surfaceElevated,
                                borderRadius: BorderRadius.circular(
                                  ZenSpacing.radiusMedium,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatEntryDate(entry.createdAt),
                                    style: theme.text.bodySmall.copyWith(
                                      color: theme.colors.onSurfaceMuted,
                                    ),
                                  ),
                                  const SizedBox(height: ZenSpacing.s8),
                                  Text(
                                    entry.body,
                                    style: theme.text.bodyLarge,
                                    maxLines: 6,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              if (hasEntries)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ActionPill(
                        label: 'write',
                        semanticLabel: 'Create new entry',
                        onTap: _openComposer,
                        icon: _PenPainter(color: theme.colors.onSurface),
                      ),
                      const SizedBox(width: ZenSpacing.s8),
                      _ActionPill(
                        label: 'voice',
                        semanticLabel: 'Start voice entry',
                        onTap: _onVoiceEntryTap,
                        icon: _MicPainter(color: theme.colors.onSurface),
                      ),
                    ],
                  ),
                ),
              if (_entryStatus != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: ZenSpacing.s64 + ZenSpacing.s24,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ZenSpacing.s12,
                        vertical: ZenSpacing.s8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colors.surfaceElevated,
                        borderRadius: BorderRadius.circular(
                          ZenSpacing.radiusMedium,
                        ),
                      ),
                      child: Text(
                        _entryStatus!,
                        style: theme.text.bodySmall.copyWith(
                          color: theme.colors.onSurfaceMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              if (_showComposer)
                Positioned.fill(
                  child: ColoredBox(
                    color: theme.colors.surface,
                    child: _buildFullScreenComposer(theme),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderChip extends StatefulWidget {
  const _ReminderChip({
    required this.label,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  @override
  State<_ReminderChip> createState() => _ReminderChipState();
}

class _ReminderChipState extends State<_ReminderChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.zenTheme;
    final reduce = ZenThemeData.reduceMotion(context);
    final bgColor = (widget.isSelected || _pressed)
        ? theme.colors.surfaceSunken
        : theme.colors.surfaceElevated;
    final textColor = widget.isDisabled
        ? theme.colors.onSurfaceFaint
        : widget.isSelected
        ? theme.colors.accent
        : theme.colors.onSurface;

    return Semantics(
      label: widget.label,
      button: true,
      selected: widget.isSelected,
      enabled: !widget.isDisabled,
      child: GestureDetector(
        onTapDown: widget.isDisabled
            ? null
            : (_) => setState(() => _pressed = true),
        onTapUp: widget.isDisabled
            ? null
            : (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.isDisabled ? null : widget.onTap,
        child: AnimatedContainer(
          duration: reduce ? Duration.zero : ZenSpacing.fast,
          curve: ZenSpacing.easeDefault,
          constraints: const BoxConstraints(minWidth: 72, minHeight: 40),
          padding: const EdgeInsets.symmetric(
            horizontal: ZenSpacing.s16,
            vertical: ZenSpacing.s8,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(ZenSpacing.radiusMedium),
          ),
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: theme.text.labelMedium.copyWith(color: textColor),
          ),
        ),
      ),
    );
  }
}

class _ActionPill extends StatefulWidget {
  const _ActionPill({
    required this.label,
    required this.semanticLabel,
    required this.onTap,
    required this.icon,
  });

  final String label;
  final String semanticLabel;
  final VoidCallback onTap;
  final CustomPainter icon;

  @override
  State<_ActionPill> createState() => _ActionPillState();
}

class _ActionPillState extends State<_ActionPill> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.zenTheme;
    final reduce = ZenThemeData.reduceMotion(context);
    return Semantics(
      label: widget.semanticLabel,
      button: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: reduce ? Duration.zero : ZenSpacing.fast,
          curve: ZenSpacing.easeDefault,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: ZenSpacing.s16),
          decoration: BoxDecoration(
            color: _pressed
                ? theme.colors.surfaceSunken
                : theme.colors.surfaceElevated,
            borderRadius: BorderRadius.circular(ZenSpacing.radiusMedium),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CustomPaint(painter: widget.icon),
              ),
              const SizedBox(width: ZenSpacing.s8),
              Text(widget.label, style: theme.text.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _PenPainter extends CustomPainter {
  const _PenPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final body = Path()
      ..moveTo(size.width * 0.24, size.height * 0.72)
      ..lineTo(size.width * 0.66, size.height * 0.30)
      ..lineTo(size.width * 0.76, size.height * 0.40)
      ..lineTo(size.width * 0.34, size.height * 0.82)
      ..close();
    canvas.drawPath(body, stroke);

    final tip = Path()
      ..moveTo(size.width * 0.24, size.height * 0.72)
      ..lineTo(size.width * 0.18, size.height * 0.88)
      ..lineTo(size.width * 0.34, size.height * 0.82)
      ..close();
    canvas.drawPath(tip, stroke);

    canvas.drawLine(
      Offset(size.width * 0.62, size.height * 0.34),
      Offset(size.width * 0.72, size.height * 0.44),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _PenPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _MicPainter extends CustomPainter {
  const _MicPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
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
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.64),
      Offset(size.width * 0.5, size.height * 0.80),
      stroke,
    );
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.84),
      Offset(size.width * 0.65, size.height * 0.84),
      stroke,
    );
    canvas.drawArc(
      Rect.fromLTWH(
        size.width * 0.22,
        size.height * 0.40,
        size.width * 0.56,
        size.height * 0.36,
      ),
      0.0,
      3.14159,
      false,
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _MicPainter oldDelegate) =>
      oldDelegate.color != color;
}

// Minimal text-only action — used in the full-screen composer toolbar.
// No container, no border. Color shift on press conveys state.
class _ComposerTextButton extends StatefulWidget {
  const _ComposerTextButton({
    required this.label,
    required this.onTap,
    this.isAccent = false,
    this.isDisabled = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isAccent;
  final bool isDisabled;

  @override
  State<_ComposerTextButton> createState() => _ComposerTextButtonState();
}

class _ComposerTextButtonState extends State<_ComposerTextButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.zenTheme;
    final reduce = ZenThemeData.reduceMotion(context);

    final Color textColor;
    if (widget.isDisabled) {
      textColor = theme.colors.onSurfaceFaint;
    } else if (widget.isAccent) {
      textColor = _pressed ? theme.colors.accentMuted : theme.colors.accent;
    } else {
      textColor = _pressed
          ? theme.colors.onSurfaceFaint
          : theme.colors.onSurfaceMuted;
    }

    return Semantics(
      button: true,
      label: widget.label,
      enabled: !widget.isDisabled,
      child: GestureDetector(
        onTapDown: widget.isDisabled
            ? null
            : (_) => setState(() => _pressed = true),
        onTapUp: widget.isDisabled
            ? null
            : (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.isDisabled ? null : widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ZenSpacing.s8,
            vertical: ZenSpacing.s8,
          ),
          child: AnimatedDefaultTextStyle(
            duration: reduce ? Duration.zero : ZenSpacing.fast,
            style: theme.text.labelMedium.copyWith(color: textColor),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}
