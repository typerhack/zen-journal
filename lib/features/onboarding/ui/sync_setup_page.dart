import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/theme.dart';
import '../../../ui/components/zen_button.dart';
import '../../../ui/components/zen_scaffold.dart';
import '../data/onboarding_state_store.dart';

class SyncSetupPage extends ConsumerStatefulWidget {
  const SyncSetupPage({super.key});

  @override
  ConsumerState<SyncSetupPage> createState() => _SyncSetupPageState();
}

class _SyncSetupPageState extends ConsumerState<SyncSetupPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/drive.appdata'],
  );

  bool _isLoading = false;
  String? _statusMessage;
  bool _statusFailed = false;

  Future<void> _continueWithGoogle() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
      _statusFailed = false;
    });

    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        setState(() {
          _statusMessage = '[failed] Google sign-in was cancelled';
          _statusFailed = true;
          _isLoading = false;
        });
        return;
      }

      await ref
          .read(onboardingControllerProvider.notifier)
          .setDriveSyncEnabled(true);
      setState(() {
        _statusMessage = '[ok] Connected to Google Drive';
        _statusFailed = false;
        _isLoading = false;
      });
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      context.go(Routes.onboardingFirstEntry);
    } catch (_) {
      setState(() {
        _statusMessage = '[failed] Could not connect to Google Drive';
        _statusFailed = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _skipForNow() async {
    await ref
        .read(onboardingControllerProvider.notifier)
        .setDriveSyncEnabled(false);
    if (!mounted) return;
    context.go(Routes.onboardingFirstEntry);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.zenTheme;
    return ZenScaffold(
      padding: const EdgeInsets.symmetric(
        horizontal: ZenSpacing.pageMarginMobile,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Your journal lives in your\nGoogle Drive - private to you.',
            style: theme.text.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ZenSpacing.s16),
          Text(
            'We cannot read your entries.\nNo account with us required.',
            style: theme.text.bodyMedium.copyWith(
              color: theme.colors.onSurfaceMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ZenSpacing.s48),
          ZenButton(
            label: 'continue with Google',
            isFullWidth: true,
            isDisabled: _isLoading,
            onTap: _continueWithGoogle,
          ),
          const SizedBox(height: ZenSpacing.s12),
          ZenButton(
            label: 'skip for now - entries stay on this device only',
            isFullWidth: true,
            isDisabled: _isLoading,
            onTap: _skipForNow,
          ),
          if (_statusMessage != null) ...[
            const SizedBox(height: ZenSpacing.s16),
            Text(
              _statusMessage!,
              style: theme.text.bodySmall.copyWith(
                color: _statusFailed
                    ? theme.colors.destructive
                    : theme.colors.onSurfaceMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
