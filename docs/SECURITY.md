# Zen Journal — App Security

## Principle

The database is encrypted, but encryption at rest only protects against
physical device theft when the device is locked. If someone picks up an
unlocked device, or if the app is visible in the system app switcher, journal
content can be exposed. These features close that gap.

---

## Biometric / Passphrase App Lock

An optional app-level lock requiring biometric authentication (Face ID,
fingerprint, or PIN fallback) before the app shows any content.

**Flutter package:** `local_auth`

**Platforms:**

| Platform | Method |
|---|---|
| iOS | Face ID / Touch ID → PIN fallback |
| Android | Fingerprint / Face / Iris → PIN fallback |
| macOS | Touch ID → Password fallback |
| Windows | Windows Hello → PIN fallback |
| Linux | Not supported — app opens directly |

### Lock behaviour

```
App launch
  → If lock enabled: show ZenLockScreen (blurred/empty, no content visible)
  → Prompt biometric authentication
  → [success] → animate into app
  → [failed / cancelled] → remain on lock screen, show [try again]
  → [too many failures] → device PIN/password required (handled by OS)

App backgrounded (> lock timeout)
  → Immediately show ZenLockScreen over content
  → Blur or replace content with surface colour — no journal text visible

App foregrounded
  → Re-authenticate if lock timeout has elapsed
```

### Lock timeout options (user configurable)

- Immediately (every time app backgrounds)
- After 1 minute
- After 5 minutes (default)
- After 15 minutes
- Never (lock disabled)

### ZenLockScreen

A minimal, calm screen — not a harsh security gate. Shows only:
- App name in display font
- A single subtle unlock affordance (`[unlock]` label with icon)
- No journal content, no entry previews, no metadata

---

## Screenshot Prevention

On platforms that support it, prevent the OS from capturing the app's content
in screenshots, screen recordings, or the app switcher thumbnail.

**Android:** `FLAG_SECURE` on the Flutter window — prevents screenshots and
hides content in the recent apps switcher.

```dart
// main.dart — Android only
if (Platform.isAndroid) {
  await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
}
```

**Flutter package:** `flutter_window_manager`

**iOS:** iOS does not allow apps to block screenshots. Mitigated by the
background blur (see below) which prevents content from appearing in the
app switcher.

**macOS / Windows / Linux:** No programmatic prevention. Mitigated by
communicating clearly that the app contains private content.

Screenshot prevention is **on by default**. Users can disable it in Settings
if they want to screenshot their own entries (e.g. to share a reflection).

---

## Background / App Switcher Blur

When the app moves to the background, journal content must not be visible
in the OS app switcher. Achieved by overlaying a blur or solid surface over
the app content before it is captured by the OS.

```dart
// Listen to app lifecycle
class _AppState extends State<App> with WidgetsBindingObserver {
  bool _obscured = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _obscured = state == AppLifecycleState.inactive ||
                  state == AppLifecycleState.paused;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main app
        ZenApp(),
        // Obscure layer — appears before OS captures screenshot
        if (_obscured)
          Positioned.fill(
            child: ZenObscureLayer(), // solid surface colour + app name
          ),
      ],
    );
  }
}
```

`ZenObscureLayer` shows the app's surface colour and the app name in the
centre — calm, branded, no content visible.

---

## Clipboard Protection

When the user copies text from a journal entry, the clipboard content is
cleared after **60 seconds**. This prevents sensitive entry text from
persisting in the clipboard indefinitely.

```dart
Future<void> copyToClipboard(String text) async {
  await Clipboard.setData(ClipboardData(text: text));
  Future.delayed(const Duration(seconds: 60), () {
    Clipboard.setData(const ClipboardData(text: ''));
  });
}
```

This is silent — no notification to the user.

---

## Settings — Security Section

```
Privacy & Security

App lock
  [toggle] Require biometric to open app
  Lock after: [5 minutes ▾]

Screenshots
  [toggle] Prevent screenshots  (on by default)
  Note: On iOS, screenshots cannot be blocked by apps.
        The app switcher preview is always hidden.

Data
  [Export my data]
  [Delete all data]
```

---

## What We Never Do

- Never log, print, or expose journal content in crash reports or analytics
- Never store authentication tokens with journal content in the same
  unprotected location
- Never show journal content in push notification previews (local
  notifications show only generic copy — never entry text)
- Never cache decrypted entry content beyond the current session
