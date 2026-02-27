# zen journal

A calm, private space to meet yourself. Zen Journal is an open-source
mindfulness journaling app built to help people improve their mindset
through intentional writing, voice input, and quiet AI reflection.

Available on iOS, Android, macOS, Windows, and Linux.

---

## What it is

Journaling works. The research is clear and the practice is simple — but
most journaling apps feel clinical, gamified, or intrusive. Zen Journal is
built around a different idea: the app itself should feel like the practice.
Calm, unhurried, yours.

- **Write or speak.** Voice transcription runs entirely on-device.
  Your audio never leaves your device.
- **A prompt to start.** A curated prompt greets you before each entry.
  Dismiss it if you want, or let it open a door.
- **Quiet AI reflection.** After you write, the app can offer a short
  observation — two to four sentences, no advice, no judgement. A mirror,
  not a coach.
- **Your data, your Drive.** Entries are stored in your own Google Drive,
  encrypted before they leave your device. We cannot read them.
- **No account with us.** No subscription, no server, no data we hold.

---

## Features

- Markdown editor with live preview (bold, italic, headings, quotes)
- Voice input via on-device Whisper (whisper.cpp on Android/Windows/Linux,
  Apple SFSpeechRecognizer on iOS/macOS)
- AI reflection and journaling prompts — three tiers:
  - DistilBERT (bundled, ~66MB) — mood and theme inference, always available
  - Gemma 2B (optional download, ~1.5GB) — written reflections and prompts
  - BYOK — bring your own OpenAI, Anthropic, OpenRouter, or Ollama key
- AES-256 encrypted SQLite database (SQLCipher)
- Google Drive sync — encrypted file only, Google never sees plaintext
- Full-text search across all entries and voice transcripts (SQLite FTS5)
- Zen light and dark themes, system-aware with manual override
- Biometric app lock (Face ID, Touch ID, fingerprint, Windows Hello)
- Data export: Markdown, JSON, PDF
- Local notifications only — no push server
- Fully offline capable

---

## Privacy

Zen Journal is privacy-first by architecture, not by policy.

- All data is encrypted on-device before anything touches disk (AES-256, SQLCipher)
- Google Drive stores only an opaque encrypted file — Google cannot read your entries
- We run no backend. There is no server in the data path.
- Voice transcription is on-device only — audio never leaves your device
- AI reflection (DistilBERT, Gemma 2B) runs on-device — entries never leave
  your device unless you configure a BYOK provider, which is clearly disclosed
- No analytics, no telemetry, no crash reporting that includes entry content
- API keys (BYOK) are stored in your device's secure enclave only — never synced

---

## Building from source

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) stable channel
- Dart 3.x (included with Flutter)
- For iOS/macOS: Xcode 15+
- For Android: Android Studio or SDK with NDK (for whisper.cpp)
- For Linux: `ninja-build`, `libgtk-3-dev`

### Setup

```bash
git clone https://github.com/typerhack/zen-journal.git
cd zen-journal-app
flutter pub get
```

### Run

```bash
# Mobile
flutter run                         # connected device or emulator

# Desktop
flutter run -d macos
flutter run -d windows
flutter run -d linux
```

### Build release

```bash
flutter build apk --release         # Android APK
flutter build appbundle --release   # Android App Bundle
flutter build ios --release         # iOS (requires Apple Developer account)
flutter build macos --release       # macOS
flutter build windows --release     # Windows
flutter build linux --release       # Linux
```

Pre-built binaries for all platforms are attached to every
[GitHub Release](../../releases), including Linux x64 and ARM64
(`.deb`, `.rpm`, `.AppImage`).

### Versioning

Zen Journal uses Semantic Versioning with git tags:

- stable: `vMAJOR.MINOR.PATCH` (example: `v0.1.0`)
- optional pre-release: `vMAJOR.MINOR.PATCH-rc.N`

Versioning, Android update rules (`versionCode` + release signing), and
required release secrets are documented in
[docs/VERSIONING.md](docs/VERSIONING.md).

---

## Google Drive setup

Zen Journal uses the Google Drive API (`drive.appdata` scope) to sync your
encrypted database to your own Drive. To build from source with sync enabled
you will need to create a Google Cloud project and configure OAuth credentials:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a project, enable the Google Drive API
3. Create OAuth 2.0 credentials (iOS, Android, and desktop clients as needed)
4. Add the credentials to the appropriate platform config files
   (see `docs/STORAGE.md` for details)

Sync is optional — the app works fully offline without a Google account.

---

## AI setup (optional)

Zen Journal works without any AI configuration:

- **DistilBERT** is bundled — mood and theme tagging work out of the box
- **Gemma 2B** downloads on first use (~1.5GB) when you tap [reflect]
- **BYOK** — if you want higher quality reflections, add your own API key
  in Settings → AI. Supported: OpenAI, Anthropic, OpenRouter, Ollama

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Key points:

- No Material or Cupertino widgets — all UI is custom
- No emojis anywhere
- All design decisions are in `docs/DESIGN_SYSTEM.md`
- Run `flutter analyze` and `dart format` before opening a PR

---

## Documentation

Full technical specifications live in `/docs`:

| Doc | Contents |
|---|---|
| [Design System](docs/DESIGN_SYSTEM.md) | Colors, typography, spacing, animation, widget rules |
| [Accessibility](docs/ACCESSIBILITY.md) | Semantics, contrast, touch targets, keyboard nav |
| [Architecture](docs/ARCHITECTURE.md) | Folder structure, Riverpod, GoRouter |
| [Storage & Sync](docs/STORAGE.md) | SQLCipher schema, FTS5, Drive sync, encryption |
| [Security](docs/SECURITY.md) | Biometric lock, screenshot prevention |
| [Voice Input](docs/VOICE.md) | whisper.cpp, Apple SFSpeechRecognizer |
| [AI](docs/AI.md) | DistilBERT, Gemma 2B, BYOK |
| [Editor](docs/EDITOR.md) | Markdown live preview, ZenEditor |
| [Onboarding](docs/ONBOARDING.md) | First-run flow |
| [Notifications](docs/NOTIFICATIONS.md) | Local reminders, scheduling |
| [Prompts Library](docs/PROMPTS.md) | Built-in prompt pool |
| [Export](docs/EXPORT.md) | Markdown, JSON, PDF, delete |
| [Open Source](docs/OPENSOURCE.md) | License, CI/CD, app stores, i18n |
| [Versioning](docs/VERSIONING.md) | SemVer, tags, Android version/signing, release file naming |

---

## License

[MIT](LICENSE)
