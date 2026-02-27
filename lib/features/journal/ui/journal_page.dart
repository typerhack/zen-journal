import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme.dart';
import '../../../ui/components/zen_scaffold.dart';
import '../../../ui/components/zen_button.dart';
import '../../onboarding/data/onboarding_state_store.dart';

class JournalPage extends ConsumerWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                                ref
                                    .read(onboardingControllerProvider.notifier)
                                    .dismissReminderNudge();
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
                    ],
                  ),
                ),
                const SizedBox(height: ZenSpacing.s24),
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
