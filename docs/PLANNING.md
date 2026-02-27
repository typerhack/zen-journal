# Zen Journal — Planning & Phases

Status legend: ✅ done · 🔲 todo · 🚧 in progress

---

## Phase 1 — Project Foundation ✅

- ✅ **Concept & stack decisions** — Chose Flutter for cross-platform (iOS, Android, macOS, Windows, Linux) with fully custom widgets; no Material or Cupertino ever.
- ✅ **CLAUDE.md rules file** — Lightweight non-negotiable rules doc (no Material, no emojis, privacy-first, accessibility required on every widget).
- ✅ **Documentation suite** — Created 11 spec docs covering design system, architecture, storage, voice, AI, accessibility, security, export, onboarding, editor, notifications, prompts, and open-source guidelines.
- ✅ **Design system** — ZenTheme InheritedWidget with ZenColors, ZenTextStyles, and ZenSpacing; light + dark tokens verified at WCAG 2.1 AA contrast.
- ✅ **App shell** — `main.dart`, `ZenJournalApp` (ConsumerStatefulWidget + WidgetsBindingObserver), background-blur obscure layer on lifecycle pause/inactive.
- ✅ **Router** — GoRouter with `/onboarding` and `/journal` named routes; no Navigator.push anywhere.
- ✅ **Core widgets** — ZenScaffold, ZenButton, ZenIconButton, ZenTextInput (EditableText-based), ZenDivider; all with Semantics and reduced-motion support.
- ✅ **Bundled fonts** — Downloaded and committed DM Serif Display, Inter (400/500/600), JetBrains Mono from Google Fonts (OFL/SIL licensed).
- ✅ **GitHub repo** — Initialised repo at github.com/typerhack/zen-journal and pushed all foundation code.

---

## Phase 2 — CI / Build Pipeline ✅

- ✅ **CI workflow** — GitHub Actions lint + test + Android + Linux jobs; fixed "Expected to find project root" error by adding `cache: true` to flutter-action.
- ✅ **Release workflow** — Full build matrix: Android APK+AAB, iOS (no-codesign), macOS Silicon, macOS Intel, macOS Universal (lipo merge), Windows x64, Windows ARM64, Linux x64, Linux ARM64.
- ✅ **Linux packaging script** — `scripts/package-linux.sh` produces `.deb`, `.rpm` (x64 only), and `.AppImage` from the Flutter bundle for a given arch and version.
- ✅ **macOS build fixes** — Raised deployment target to 14.0, added pre_install hook to allow onnxruntime static lib, suppressed SQLCipher compiler warnings with `inhibit_all_warnings!`, bumped all outdated pod deployment targets to 14.0 in post_install.
- ✅ **Dart format / analyzer** — All `lib/` and `test/` files pass `dart format` and `flutter analyze` with zero issues.
- ✅ **Widget test** — Fixed Directionality crash (moved Stack inside WidgetsApp builder); `flutter test` passes 1/1.

---

## Phase 3 — Onboarding & Navigation 🔲

- 🔲 **Welcome screen** — Animated zen tagline, "begin" button, system theme detection on first launch.
- 🔲 **Theme onboarding step** — Let user confirm or override light/dark; persist choice with shared_preferences.
- 🔲 **Permission prompts** — Microphone (for voice), notification permission; explain why before requesting.
- 🔲 **First-run journal prompt** — Show a starter prompt to lower blank-page anxiety.

---

## Phase 4 — Storage Layer 🔲

- 🔲 **SQLCipher setup** — Open encrypted database on first launch; generate AES-256 key and store in flutter_secure_storage.
- 🔲 **Schema & migrations** — Create all tables (entries, voice_transcripts, entry_moods, entry_themes, entry_reflections, settings) with versioned migration runner.
- 🔲 **FTS5 search index** — Standalone virtual table with triggers for both entries and voice_transcripts tables; query uses `entry_id` column.
- 🔲 **Repository layer** — EntryRepository, SettingsRepository with Riverpod AsyncNotifierProvider; no raw SQL leaking into UI.

---

## Phase 5 — Journal Core 🔲

- 🔲 **Entry list screen** — Chronological list of entries; swipe-to-delete, tap to open; empty state with prompt.
- 🔲 **ZenEditor** — Markdown live-preview built on EditableText; inline bold/italic/heading rendering via custom TextSpan parser.
- 🔲 **Entry save / auto-save** — Debounced auto-save every 3 s; manual save button; entry timestamps (created_at, updated_at).
- 🔲 **Prompt library** — Built-in set of mindfulness prompts shown on new entry; shuffle and pin favourite.

---

## Phase 6 — Voice Input 🔲

- 🔲 **Audio recording** — Use `record` package; show waveform animation while recording; save raw audio to temp file.
- 🔲 **Transcription — Apple platforms** — SFSpeechRecognizer on iOS/macOS; no model download required.
- 🔲 **Transcription — other platforms** — whisper.cpp via flutter plugin on Android/Windows/Linux; lazy download of tiny model (~75 MB) on first use.
- 🔲 **Transcript persistence** — Store transcript in `voice_transcripts` table; FTS trigger re-indexes entry automatically.

---

## Phase 7 — AI Features 🔲

- 🔲 **DistilBERT classification (Tier 1)** — Re-add `flutter_onnxruntime`; load bundled ONNX model; classify mood and themes on every save.
- 🔲 **Gemma 2B reflection (Tier 2)** — Re-add `flutter_gemma`; optional ~1.5 GB model download; generate 2–4 sentence reflections in the user's tone.
- 🔲 **BYOK (Tier 3)** — Settings screen for OpenAI, Anthropic, OpenRouter, Ollama keys; store only in flutter_secure_storage, never in Drive.
- 🔲 **Mood / theme visualisation** — Weekly mood graph; theme word cloud; shown on journal home.

---

## Phase 8 — Sync & Encryption 🔲

- 🔲 **Google Sign-In** — Prompt after onboarding; request drive.appdata scope only.
- 🔲 **Drive sync** — Upload encrypted `.db` file (30 s debounce); ETag-based optimistic concurrency; entry-level merge on conflict.
- 🔲 **Cross-device key — Path A** — Platform backup (iCloud Keychain / Android Keystore Backup) for same-ecosystem devices.
- 🔲 **Cross-device key — Path B** — Argon2id-derived key from passphrase; wrapped key stored in Drive appDataFolder for cross-platform recovery.

---

## Phase 9 — Notifications & Reminders 🔲

- 🔲 **Daily reminder scheduling** — Rolling 14-day batch of individual `zonedSchedule` calls with unique copy each; cancel IDs 0–13 only when rescheduling.
- 🔲 **Weekly digest** — Single notification ID 100; summary of mood trends and streaks.
- 🔲 **Notification settings screen** — Time picker, toggle per type, quiet-hours window.

---

## Phase 10 — Security & Privacy 🔲

- 🔲 **Biometric lock** — local_auth Face ID / fingerprint / Windows Hello gate on app resume.
- 🔲 **Screenshot prevention** — FLAG_SECURE on Android; background blur on all platforms via obscure layer (already in app shell).
- 🔲 **Clipboard auto-clear** — Clear any text copied from the app after 60 s.

---

## Phase 11 — Export & Data Portability 🔲

- 🔲 **Markdown export** — One file per entry or combined archive; filename = date + slug.
- 🔲 **JSON export** — Full structured dump including moods, themes, transcripts.
- 🔲 **PDF export** — Styled with zen typography via the `pdf` package.
- 🔲 **Delete all data** — Wipe local DB and Drive files; confirm with biometric or passphrase.

---

## Phase 12 — Polish & Release 🔲

- 🔲 **App icon** — Design and export to all required sizes for iOS, Android, macOS, Windows, Linux.
- 🔲 **Splash / launch screen** — Minimal zen wordmark; respects reduced-motion.
- 🔲 **Accessibility audit** — Screen reader walkthrough, keyboard nav, contrast re-check on real devices.
- 🔲 **Android build validation** — Run CI Android job end-to-end; test on physical device.
- 🔲 **iOS TestFlight** — Codesign setup, provisioning profiles, first internal build.
- 🔲 **App Store / Play Store listings** — Screenshots, descriptions, privacy policy page.
- 🔲 **v0.1.0 tag & release** — Tag triggers release workflow; all platform artifacts published to GitHub Releases.
