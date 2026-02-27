import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import '../../../core/theme/theme.dart';
import '../../../ui/components/zen_scaffold.dart';
import '../../../ui/components/zen_button.dart';
import '../../onboarding/data/onboarding_state_store.dart';

class JournalPage extends ConsumerStatefulWidget {
  const JournalPage({super.key});

  @override
  ConsumerState<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends ConsumerState<JournalPage> {
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

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final theme = context.zenTheme;
    final onboardingState = ref.watch(onboardingControllerProvider);

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
          child: Column(
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
                                    .read(onboardingControllerProvider.notifier)
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
                            return SizedBox(
                              width: 120,
                              child: ZenButton(
                                label: option.label,
                                isFullWidth: true,
                                isDisabled: _requestingPermission,
                                onTap: () {
                                  setState(
                                    () => _selectedReminderIndex = index,
                                  );
                                },
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
              if (state.firstEntryText != null &&
                  state.firstEntryText!.isNotEmpty)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(ZenSpacing.s16),
                    decoration: BoxDecoration(
                      color: theme.colors.surfaceElevated,
                      borderRadius: BorderRadius.circular(
                        ZenSpacing.radiusMedium,
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        state.firstEntryText!,
                        style: theme.text.bodyLarge,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Center(
                    child: Text(
                      'Your entries will appear here.',
                      style: theme.text.bodyMedium.copyWith(
                        color: theme.colors.onSurfaceMuted,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
