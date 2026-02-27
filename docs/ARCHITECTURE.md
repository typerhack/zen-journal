# Zen Journal — Architecture

## Folder Structure

```
lib/
├── main.dart
├── app.dart                        # App root, theme wiring, routing, lifecycle observer
├── core/
│   ├── theme/
│   │   ├── zen_theme.dart          # ZenTheme InheritedWidget
│   │   ├── zen_colors.dart         # ZenColors token class (light + dark)
│   │   ├── zen_text.dart           # ZenTextStyles token class
│   │   └── zen_spacing.dart        # Spacing, radius, animation tokens
│   ├── router/
│   │   └── app_router.dart         # GoRouter configuration, named routes
│   ├── crypto/
│   │   ├── key_manager.dart        # Encryption key generation, secure storage, wrapping
│   │   └── argon2_wrapper.dart     # Argon2id wrapping for Drive backup (Path B)
│   ├── db/
│   │   ├── database.dart           # SQLCipher open/close, migration runner
│   │   └── migrations/             # Versioned schema migration files
│   └── utils/
│       ├── debouncer.dart
│       └── clipboard.dart          # Clipboard clear-after-60s helper
├── features/
│   ├── journal/
│   │   ├── data/                   # DB queries, entry repository
│   │   ├── domain/                 # Entry model, mood/theme enums
│   │   └── ui/                     # Entry list, entry editor, entry detail pages
│   ├── ai/
│   │   ├── data/
│   │   │   ├── distilbert_service.dart   # ONNX Runtime inference (mood, themes)
│   │   │   ├── gemma_service.dart        # flutter_gemma inference (reflection, prompts)
│   │   │   └── byok_service.dart         # OpenAI / Anthropic / OpenRouter / Ollama
│   │   ├── domain/
│   │   │   └── ai_service.dart           # Abstract AiService interface
│   │   └── ui/                           # Reflection card, prompt display
│   ├── voice/
│   │   ├── data/
│   │   │   ├── whisper_service.dart      # whisper.cpp via flutter plugin (Android/Win/Linux)
│   │   │   └── apple_speech_service.dart # SFSpeechRecognizer (iOS/macOS)
│   │   ├── domain/
│   │   │   └── voice_service.dart        # Abstract VoiceService interface
│   │   └── ui/                           # Mic button, waveform, model download prompt
│   ├── sync/
│   │   ├── drive_service.dart            # Google Drive API, OAuth, upload/download
│   │   └── sync_manager.dart             # Sync orchestration, conflict resolution
│   ├── search/
│   │   ├── search_repository.dart        # FTS5 queries, snippet extraction
│   │   └── ui/                           # Search bar, results list
│   ├── export/
│   │   ├── markdown_exporter.dart
│   │   ├── json_exporter.dart
│   │   └── pdf_exporter.dart
│   ├── onboarding/
│   │   └── ui/                           # Welcome, Google sign-in, first entry
│   ├── notifications/
│   │   └── notification_scheduler.dart   # Local notification batch scheduling
│   └── settings/
│       └── ui/                           # Theme, AI provider, security, export
├── services/
│   └── secure_storage.dart               # flutter_secure_storage wrapper
└── ui/
    ├── components/                        # All reusable custom widgets
    │   ├── zen_button.dart
    │   ├── zen_text_field.dart            # EditableText-based, not TextField
    │   └── ...
    └── pages/                             # Top-level page shells
```

---

## State Management

**Riverpod** throughout.

| Provider type | When to use |
|---|---|
| `Provider` | Pure computed / constant values |
| `StateNotifierProvider` | Mutable state with business logic |
| `FutureProvider` | Single async fetch (DB read, Drive check) |
| `StreamProvider` | Ongoing streams (voice amplitude, sync status) |
| `AsyncNotifierProvider` | Async state with mutations (entry CRUD) |

No `setState` outside isolated animation widgets. No `ChangeNotifier`.

---

## Routing

**GoRouter** with named routes. No `Navigator.push` directly.

```dart
// Route names as constants
abstract class Routes {
  static const onboarding = '/onboarding';
  static const journal    = '/journal';
  static const editor     = '/journal/editor';
  static const entry      = '/journal/entry/:id';
  static const search     = '/search';
  static const settings   = '/settings';
}
```

GoRouter redirect guard checks: first-run (→ onboarding), app-lock state
(→ lock screen), before allowing access to journal routes.

---

## Dependency Injection

Riverpod providers declared at feature level. No global service locator.
Platform-specific implementations injected at the provider level:

```dart
final voiceServiceProvider = Provider<VoiceService>((ref) {
  if (Platform.isIOS || Platform.isMacOS) {
    return AppleSpeechService();
  }
  return WhisperCppService(ref.watch(whisperModelProvider));
});
```

---

## Error Handling Strategy

- DB errors: surface as `AsyncError` in Riverpod providers — UI shows
  inline `[failed]` state, never crashes
- Drive sync errors: logged locally, retried on next open — never blocks
  the user from writing
- AI errors: graceful degradation — missing reflection is acceptable,
  broken write is not
- Voice transcription errors: inline `[failed — try again]` below editor
- No error dialogs or modals — all errors are inline, calm, non-blocking

---

## Platform Notes

| Platform | Key considerations |
|---|---|
| iOS | `SFSpeechRecognizer`, iCloud Keychain sync, `local_auth` Face ID/Touch ID |
| Android | whisper.cpp, Android Keystore Backup, `FLAG_SECURE`, fingerprint |
| macOS | `SFSpeechRecognizer`, Keychain, Touch ID, menubar integration |
| Windows | whisper.cpp, DPAPI, Windows Hello, no screenshot prevention API |
| Linux | whisper.cpp, Secret Service / file fallback, no biometric support |
