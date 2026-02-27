# Zen Journal — Planning & Phases

Status legend: [done] done | [todo] todo | [wip] in progress

---

## Phase 1 — Project Foundation [done]

- [done] **Concept & stack decisions** — Chose Flutter for cross-platform (iOS, Android, macOS, Windows, Linux) with fully custom widgets; no Material or Cupertino ever.
- [done] **CLAUDE.md rules file** — Lightweight non-negotiable rules doc (no Material, no emojis, privacy-first, accessibility required on every widget).
- [done] **Documentation suite** — Created and maintained 14 spec docs covering design system, architecture, storage, voice, AI, accessibility, security, export, onboarding, editor, notifications, prompts, planning, and open-source guidelines.
- [done] **Design system** — ZenTheme InheritedWidget with ZenColors, ZenTextStyles, and ZenSpacing; light + dark tokens verified at WCAG 2.1 AA contrast.
- [done] **App shell** — `main.dart`, `ZenJournalApp` (ConsumerStatefulWidget + WidgetsBindingObserver), background-blur obscure layer on lifecycle pause/inactive.
- [done] **Router** — GoRouter with `/onboarding` and `/journal` named routes; no Navigator.push anywhere.
- [done] **Core widgets** — ZenScaffold, ZenButton, ZenIconButton, ZenTextInput (EditableText-based), ZenDivider; all with Semantics and reduced-motion support.
- [done] **Bundled fonts** — Downloaded and committed DM Serif Display, Inter (400/500/600), JetBrains Mono from Google Fonts (OFL/SIL licensed).
- [done] **GitHub repo** — Initialised repo at github.com/typerhack/zen-journal and pushed all foundation code.

---

## Phase 2 — CI / Build Pipeline [done]

- [done] **CI workflow** — GitHub Actions lint + test + build validation for Android, iOS (no-codesign), macOS Apple Silicon, macOS Intel, Windows x64, Linux x64, and Linux ARM64.
- [done] **Release workflow** — Full build matrix: Android APK+AAB, iOS (no-codesign), macOS Silicon, macOS Intel, Windows x64, Windows ARM64, Linux x64, Linux ARM64.
- [done] **Linux packaging script** — `scripts/package-linux.sh` produces `.deb`, `.rpm`, and `.AppImage` for both x64 and ARM64 from the Flutter bundle for a given arch and version.
- [done] **macOS build fixes** — Raised deployment target to 14.0, added pre_install hook to allow onnxruntime static lib, suppressed SQLCipher compiler warnings with `inhibit_all_warnings!`, bumped all outdated pod deployment targets to 14.0 in post_install.
- [done] **Dart format / analyzer** — All `lib/` and `test/` files pass `dart format` and `flutter analyze` with zero issues.
- [done] **Widget test** — Fixed Directionality crash (moved Stack inside WidgetsApp builder); `flutter test` passes 1/1.

---

## Phase 3 — Onboarding & Navigation [done]

- [done] **Welcome screen** — Calm hero copy and "begin" CTA routed into onboarding flow.
- [done] **Theme onboarding step** — User can keep system theme or override light/dark; persisted with shared_preferences.
- [done] **Permission prompts** — Microphone requested in context on mic tap; reminder prompt deferred to day 2/second-entry condition.
- [done] **First-run journal prompt** — Starter first-entry prompt implemented; saved text carries into journal home after onboarding.

---

## Phase 4 — Storage Layer [done]

- [done] **SQLCipher setup** — Encrypted database opens on first launch with a 256-bit CSPRNG key stored in the platform secure enclave via flutter_secure_storage (iOS/macOS Keychain, Android Keystore, Windows DPAPI, Linux Secret Service). Migration path handles existing installs that used the interim SharedPreferences store.
- [done] **Schema & migrations** — Core tables and versioned migration runner implemented. All CREATE statements use IF NOT EXISTS for idempotency.
- [done] **FTS5 search index** — Standalone virtual table and triggers for entries + voice_transcripts implemented. FTS5 creation is wrapped in try/catch — graceful fallback on Android system SQLite builds that omit FTS5. DB recovery logic deletes and recreates the file if a broken migration state is detected on open.
- [done] **Repository layer** — EntryRepository, SettingsRepository, and Riverpod AsyncNotifierProvider integration implemented.

---

## Phase 5 — Journal Core [todo]

- [todo] **Entry list screen** — Chronological list of entries; swipe-to-delete, tap to open; empty state with prompt.
- [todo] **ZenEditor** — Markdown live-preview built on EditableText; inline bold/italic/heading rendering via custom TextSpan parser.
- [todo] **Entry save / auto-save** — Debounced auto-save every 3 s; manual save button; entry timestamps (created_at, updated_at).
- [todo] **Prompt library** — Built-in set of mindfulness prompts shown on new entry; shuffle and pin favourite.

---

## Phase 6 — Voice Input [todo]

- [todo] **Audio recording** — Use `record` package; show waveform animation while recording; save raw audio to temp file.
- [todo] **Transcription — Apple platforms** — SFSpeechRecognizer on iOS/macOS; no model download required.
- [todo] **Transcription — other platforms** — whisper.cpp via flutter plugin on Android/Windows/Linux; lazy download of tiny model (~75 MB) on first use.
- [todo] **Transcript persistence** — Store transcript in `voice_transcripts` table; FTS trigger re-indexes entry automatically.

---

## Phase 7 — AI Features [todo]

- [todo] **DistilBERT classification (Tier 1)** — Re-add `flutter_onnxruntime`; load bundled ONNX model; classify mood and themes on every save.
- [todo] **Gemma 2B reflection (Tier 2)** — Re-add `flutter_gemma`; optional ~1.5 GB model download; generate 2–4 sentence reflections in the user's tone.
- [todo] **BYOK (Tier 3)** — Settings screen for OpenAI, Anthropic, OpenRouter, Ollama keys; store only in flutter_secure_storage, never in Drive.
- [todo] **Mood / theme visualisation** — Weekly mood graph; theme word cloud; shown on journal home.

---

## Phase 8 — Sync & Encryption [todo]

- [todo] **Google Sign-In** — Prompt after onboarding; request drive.appdata scope only.
- [todo] **Drive sync** — Upload encrypted `.db` file (30 s debounce); ETag-based optimistic concurrency; entry-level merge on conflict.
- [todo] **Cross-device key — Path A** — Platform backup (iCloud Keychain / Android Keystore Backup) for same-ecosystem devices.
- [todo] **Cross-device key — Path B** — Argon2id-derived key from passphrase; wrapped key stored in Drive appDataFolder for cross-platform recovery.

---

## Phase 9 — Notifications & Reminders [todo]

- [todo] **Daily reminder scheduling** — Rolling 14-day batch of individual `zonedSchedule` calls with unique copy each; cancel IDs 0–13 only when rescheduling.
- [todo] **Weekly digest** — Single notification ID 100; summary of mood trends and streaks.
- [todo] **Notification settings screen** — Time picker, toggle per type, quiet-hours window.

---

## Phase 10 — Security & Privacy [todo]

- [todo] **Biometric lock** — local_auth Face ID / fingerprint / Windows Hello gate on app resume.
- [todo] **Screenshot prevention** — FLAG_SECURE on Android; background blur on all platforms via obscure layer (already in app shell).
- [todo] **Clipboard auto-clear** — Clear any text copied from the app after 60 s.

---

## Phase 11 — Export & Data Portability [todo]

- [todo] **Markdown export** — One file per entry or combined archive; filename = date + slug.
- [todo] **JSON export** — Full structured dump including moods, themes, transcripts.
- [todo] **PDF export** — Styled with zen typography via the `pdf` package.
- [todo] **Delete all data** — Wipe local DB and Drive files; confirm with biometric or passphrase.

---

## Phase 12 — Polish & Release [todo]

- [todo] **App icon** — Design and export to all required sizes for iOS, Android, macOS, Windows, Linux.
- [todo] **Splash / launch screen** — Minimal zen wordmark; respects reduced-motion.
- [todo] **Accessibility audit** — Screen reader walkthrough, keyboard nav, contrast re-check on real devices.
- [todo] **Android build validation** — Run CI Android job end-to-end; test on physical device.
- [todo] **iOS TestFlight** — Codesign setup, provisioning profiles, first internal build.
- [todo] **App Store / Play Store listings** — Screenshots, descriptions, privacy policy page.
- [todo] **v0.1.2 tag & release** — Tag triggers release workflow; all platform artifacts published to GitHub Releases.
