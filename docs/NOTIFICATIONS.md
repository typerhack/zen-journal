# Zen Journal — Notifications

## Principle

A notification from a journaling app should feel like a quiet tap on the
shoulder — not a demand. The copy never guilts, never tracks streaks, never
says "you missed yesterday". It simply opens a door.

Local notifications only. No push server. No account. No data transmitted.

**Flutter package:** `flutter_local_notifications`

---

## Permission Request

Never requested during onboarding. Deferred to day 2 / second entry
(see ONBOARDING.md). Requested only after the user has chosen to set
a reminder — permission is contextual, not anticipatory.

---

## Notification Types

### Daily Reminder (opt-in)

A single daily notification at a user-chosen time. Off by default.

**Copy pool — rotated randomly, never the same twice in a row:**

```
A moment is waiting for you.
There is something worth writing today.
A few minutes with yourself?
Your journal is open.
The page is ready when you are.
What is on your mind today?
A quiet space is waiting.
```

Rules:
- Copy is warm, not urgent
- No mention of streaks, days missed, or goals
- No personalisation using entry data in the notification
- Notification title: `zen journal` (lowercase, always)
- No notification sound — vibration only on mobile, silent on desktop

### Weekly Digest (opt-in, separate from daily reminder)

One notification per week (user chooses day, defaults to Sunday morning)
when a weekly AI digest is ready. Only sent if the user has written at
least 2 entries that week.

```
Title: zen journal
Body:  Your week in reflection is ready.
```

Tapping opens directly to the weekly digest view.

---

## Scheduling

**Do not use `periodicallyShow`.** It schedules a single copy that repeats
forever, breaking the rotation requirement.

Instead, schedule a **rolling batch of 14 individual future notifications**,
each with a different copy drawn from the pool without repetition.

```dart
// Notification ID ranges — must never overlap
// Daily reminders : 0 – 13   (14 slots, one per day in the rolling batch)
// Weekly digest   : 100       (single ID, rescheduled when digest is ready)
abstract class NotificationIds {
  static const int dailyStart  = 0;
  static const int dailyEnd    = 13;   // inclusive
  static const int weeklyDigest = 100;
}

// Schedule 14 days of daily reminders with unique copy each
Future<void> scheduleDailyReminders(TimeOfDay time) async {
  // Cancel only daily reminder IDs — weekly digest is untouched
  for (int id = NotificationIds.dailyStart; id <= NotificationIds.dailyEnd; id++) {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  final copies = _uniqueCopySample(14); // shuffled, no consecutive repeats
  final now = DateTime.now();

  for (int i = 0; i < 14; i++) {
    final scheduledDate = _nextOccurrence(time, now, daysAhead: i + 1);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      NotificationIds.dailyStart + i,
      'zen journal',
      copies[i],
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
```

**Batch refresh:** When the app opens, check how many daily reminder
notifications remain. If fewer than 7, cancel the existing daily reminder IDs
(0–13) and reschedule a fresh 14-day batch. The weekly digest notification
(ID 100) is unaffected. This ensures rotation continues indefinitely without
server involvement.

```dart
// In app startup — after auth, before showing journal
Future<void> refreshNotificationsIfNeeded() async {
  final pending =
      await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  if (pending.length < 7) {
    final prefs = ref.read(settingsProvider);
    if (prefs.dailyReminderEnabled) {
      await scheduleDailyReminders(prefs.reminderTime);
    }
  }
}
```

---

## Settings — Notifications

```
Reminders

Daily reminder
  [toggle] — off by default
  Time: [08:00 ▾]          ← shown only when toggle is on

Weekly digest
  [toggle] — off by default
  Day: [Sunday ▾]           ← shown only when toggle is on
```

No other notification types. No marketing, no tips, no "new feature"
notifications.

---

## What We Never Do

- No streaks, missed day guilt, or gamification in notification copy
- No notification that includes any entry content or AI output
- No notification sound — silence respects context
- No badge count on the app icon
- No notification channels beyond the two above
