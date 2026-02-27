import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingState {
  const OnboardingState({
    required this.isComplete,
    required this.driveSyncEnabled,
    required this.themePreference,
    required this.firstEntryText,
    required this.firstEntrySavedAtIso,
    required this.entryCount,
    required this.notificationNudgeDismissed,
    required this.reminderEnabled,
    required this.reminderHour,
    required this.reminderMinute,
  });

  final bool isComplete;
  final bool driveSyncEnabled;
  final AppThemePreference themePreference;
  final String? firstEntryText;
  final String? firstEntrySavedAtIso;
  final int entryCount;
  final bool notificationNudgeDismissed;
  final bool reminderEnabled;
  final int? reminderHour;
  final int? reminderMinute;

  bool get shouldShowReminderNudge {
    if (notificationNudgeDismissed) return false;
    if (entryCount >= 2) return true;
    final firstSavedAt = _parseIsoDate(firstEntrySavedAtIso);
    if (firstSavedAt == null) return false;
    final now = DateTime.now();
    final firstDay = DateTime(
      firstSavedAt.year,
      firstSavedAt.month,
      firstSavedAt.day,
    );
    final currentDay = DateTime(now.year, now.month, now.day);
    return currentDay.isAfter(firstDay);
  }

  static DateTime? _parseIsoDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}

enum AppThemePreference { system, light, dark }

class OnboardingController extends AsyncNotifier<OnboardingState> {
  static const _isCompleteKey = 'onboarding.is_complete';
  static const _driveSyncEnabledKey = 'onboarding.drive_sync_enabled';
  static const _themePreferenceKey = 'onboarding.theme_preference';
  static const _firstEntryTextKey = 'journal.first_entry_text';
  static const _firstEntrySavedAtKey = 'journal.first_entry_saved_at';
  static const _entryCountKey = 'journal.entry_count';
  static const _notificationNudgeDismissedKey = 'notifications.nudge_dismissed';
  static const _reminderEnabledKey = 'notifications.reminder_enabled';
  static const _reminderHourKey = 'notifications.reminder_hour';
  static const _reminderMinuteKey = 'notifications.reminder_minute';

  @override
  Future<OnboardingState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTheme = prefs.getString(_themePreferenceKey);
    return OnboardingState(
      isComplete: prefs.getBool(_isCompleteKey) ?? false,
      driveSyncEnabled: prefs.getBool(_driveSyncEnabledKey) ?? false,
      themePreference: _themeFromString(storedTheme),
      firstEntryText: prefs.getString(_firstEntryTextKey),
      firstEntrySavedAtIso: prefs.getString(_firstEntrySavedAtKey),
      entryCount: prefs.getInt(_entryCountKey) ?? 0,
      notificationNudgeDismissed:
          prefs.getBool(_notificationNudgeDismissedKey) ?? false,
      reminderEnabled: prefs.getBool(_reminderEnabledKey) ?? false,
      reminderHour: prefs.getInt(_reminderHourKey),
      reminderMinute: prefs.getInt(_reminderMinuteKey),
    );
  }

  Future<void> setDriveSyncEnabled(bool enabled) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_driveSyncEnabledKey, enabled);
    state = AsyncData(
      OnboardingState(
        isComplete: current.isComplete,
        driveSyncEnabled: enabled,
        themePreference: current.themePreference,
        firstEntryText: current.firstEntryText,
        firstEntrySavedAtIso: current.firstEntrySavedAtIso,
        entryCount: current.entryCount,
        notificationNudgeDismissed: current.notificationNudgeDismissed,
        reminderEnabled: current.reminderEnabled,
        reminderHour: current.reminderHour,
        reminderMinute: current.reminderMinute,
      ),
    );
  }

  Future<void> setThemePreference(AppThemePreference preference) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePreferenceKey, preference.name);
    state = AsyncData(
      OnboardingState(
        isComplete: current.isComplete,
        driveSyncEnabled: current.driveSyncEnabled,
        themePreference: preference,
        firstEntryText: current.firstEntryText,
        firstEntrySavedAtIso: current.firstEntrySavedAtIso,
        entryCount: current.entryCount,
        notificationNudgeDismissed: current.notificationNudgeDismissed,
        reminderEnabled: current.reminderEnabled,
        reminderHour: current.reminderHour,
        reminderMinute: current.reminderMinute,
      ),
    );
  }

  Future<void> saveFirstEntry(String text) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final nowIso = DateTime.now().toIso8601String();
    final nextEntryCount = current.entryCount > 0 ? current.entryCount : 1;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_firstEntryTextKey, text);
    await prefs.setString(_firstEntrySavedAtKey, nowIso);
    await prefs.setInt(_entryCountKey, nextEntryCount);
    state = AsyncData(
      OnboardingState(
        isComplete: current.isComplete,
        driveSyncEnabled: current.driveSyncEnabled,
        themePreference: current.themePreference,
        firstEntryText: text,
        firstEntrySavedAtIso: nowIso,
        entryCount: nextEntryCount,
        notificationNudgeDismissed: current.notificationNudgeDismissed,
        reminderEnabled: current.reminderEnabled,
        reminderHour: current.reminderHour,
        reminderMinute: current.reminderMinute,
      ),
    );
  }

  Future<void> enableReminder({required int hour, required int minute}) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderEnabledKey, true);
    await prefs.setInt(_reminderHourKey, hour);
    await prefs.setInt(_reminderMinuteKey, minute);
    await prefs.setBool(_notificationNudgeDismissedKey, true);
    state = AsyncData(
      OnboardingState(
        isComplete: current.isComplete,
        driveSyncEnabled: current.driveSyncEnabled,
        themePreference: current.themePreference,
        firstEntryText: current.firstEntryText,
        firstEntrySavedAtIso: current.firstEntrySavedAtIso,
        entryCount: current.entryCount,
        notificationNudgeDismissed: true,
        reminderEnabled: true,
        reminderHour: hour,
        reminderMinute: minute,
      ),
    );
  }

  Future<void> dismissReminderNudge() async {
    final current = state.valueOrNull;
    if (current == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationNudgeDismissedKey, true);
    state = AsyncData(
      OnboardingState(
        isComplete: current.isComplete,
        driveSyncEnabled: current.driveSyncEnabled,
        themePreference: current.themePreference,
        firstEntryText: current.firstEntryText,
        firstEntrySavedAtIso: current.firstEntrySavedAtIso,
        entryCount: current.entryCount,
        notificationNudgeDismissed: true,
        reminderEnabled: current.reminderEnabled,
        reminderHour: current.reminderHour,
        reminderMinute: current.reminderMinute,
      ),
    );
  }

  Future<void> completeOnboarding() async {
    final current = state.valueOrNull;
    if (current == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isCompleteKey, true);
    state = AsyncData(
      OnboardingState(
        isComplete: true,
        driveSyncEnabled: current.driveSyncEnabled,
        themePreference: current.themePreference,
        firstEntryText: current.firstEntryText,
        firstEntrySavedAtIso: current.firstEntrySavedAtIso,
        entryCount: current.entryCount,
        notificationNudgeDismissed: current.notificationNudgeDismissed,
        reminderEnabled: current.reminderEnabled,
        reminderHour: current.reminderHour,
        reminderMinute: current.reminderMinute,
      ),
    );
  }

  AppThemePreference _themeFromString(String? value) {
    for (final item in AppThemePreference.values) {
      if (item.name == value) return item;
    }
    return AppThemePreference.system;
  }
}

final onboardingControllerProvider =
    AsyncNotifierProvider<OnboardingController, OnboardingState>(
      OnboardingController.new,
    );
