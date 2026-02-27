# Zen Journal — Claude Instructions

## Project Overview

Zen Journal is a cross-platform mindfulness journaling app built with Flutter.
The goal is to help people improve their mindset and feel better through intentional
journaling, voice input, and AI-powered reflection. The experience itself — the design,
the feel, the pace — should reinforce the zen philosophy.

**Platforms:** iOS, Android, macOS, Windows, Linux

## Tech Stack

| Layer | Choice |
|---|---|
| Framework | Flutter (Dart) — fully custom widget system |
| Local Storage | SQLCipher (AES-256 encrypted SQLite) via `sqlcipher_flutter_libs` |
| Sync | Google Drive API — syncs encrypted `.db` file only, plaintext never leaves device |
| Key Storage | `flutter_secure_storage` — iOS Keychain, Android Keystore, macOS Keychain, Windows DPAPI |
| Voice Input | On-device Whisper — `whisper.cpp` (Android/Windows/Linux) + Apple `SFSpeechRecognizer` (iOS/macOS) |
| AI — Classification | DistilBERT fine-tuned, ONNX Runtime (~66MB, bundled) |
| AI — Generative | Gemma 2B fine-tuned, flutter_gemma (~1.5GB, optional download) |
| AI — BYOK | OpenAI / Anthropic / OpenRouter / Ollama (user's own key) |
| Themes | Zen light + Dark, system-aware with manual override |

## Documentation

All detailed specs live in `/docs`. Always consult the relevant doc before
implementing a feature.

| Doc | Purpose |
|---|---|
| [Design System](docs/DESIGN_SYSTEM.md) | Colors, typography, spacing, animation, custom widget rules |
| [Accessibility](docs/ACCESSIBILITY.md) | Semantics, touch targets, contrast, font scaling, keyboard nav |
| [Architecture](docs/ARCHITECTURE.md) | Folder structure, state management, conventions |
| [Storage & Sync](docs/STORAGE.md) | SQLCipher schema, FTS5 search, Google Drive sync, encryption |
| [Security](docs/SECURITY.md) | Biometric lock, screenshot prevention, background blur, clipboard |
| [Voice Input](docs/VOICE.md) | On-device Whisper, whisper.cpp, Apple SFSpeechRecognizer |
| [AI](docs/AI.md) | DistilBERT, Gemma 2B, BYOK (OpenAI/Anthropic/OpenRouter/Ollama) |
| [Editor](docs/EDITOR.md) | Markdown live preview, supported syntax, UX rules |
| [Onboarding](docs/ONBOARDING.md) | First-run flow, permission strategy, first entry |
| [Notifications](docs/NOTIFICATIONS.md) | Local reminders, copy guidelines, scheduling |
| [Prompts Library](docs/PROMPTS.md) | Built-in prompt pool, rotation rules, free write |
| [Export](docs/EXPORT.md) | Markdown, JSON, PDF export, delete all data |
| [Open Source](docs/OPENSOURCE.md) | License, CI/CD, app stores, contributing, i18n |
| [Versioning](docs/VERSIONING.md) | SemVer policy, release tags, Android signing/version variables |

## Core Rules

### UI & Design

- **NEVER use Flutter built-in Material or Cupertino widgets.** No `Scaffold`,
  `AppBar`, `ElevatedButton`, `TextField`, `BottomNavigationBar`, `Drawer`, etc.
- **ALL UI components are custom-built** from `StatelessWidget` / `StatefulWidget`
  or `CustomPainter` following the principles in [Design System](docs/DESIGN_SYSTEM.md).
- Every widget must support both zen (light) and dark themes via `ZenTheme`.
- Animations must follow the timing and easing rules in the design system — no
  instant transitions, no linear easing.
- **Emojis are prohibited everywhere** — UI, copy, code comments, error messages,
  onboarding, documentation. No exceptions.
- Icons must come from an approved SVG library (Lucide, Phosphor, Tabler) or be
  custom-painted. Never use `Icons.*` or `CupertinoIcons.*`.
- Status feedback uses bracketed text labels: `[ok]` `[success]` `[failed]`
  `[warning]` `[pending]` — styled with the appropriate `ZenTheme` color token.
- Whitespace is a design element. Do not fill space for the sake of it.
- **Every custom widget must pass the accessibility checklist** in
  [Accessibility](docs/ACCESSIBILITY.md) before it is considered complete.
  Semantics, touch targets, contrast, font scaling, and keyboard nav are
  mandatory — not optional enhancements.

### Code

- Use Dart null safety throughout. No `!` force-unwrap without a comment explaining why.
- State management: Riverpod. No `setState` outside of isolated leaf widgets.
- All colors, text styles, spacing, and radii come from `ZenTheme` tokens — no
  hardcoded values.
- File names: `snake_case.dart`. Class names: `PascalCase`. Private members: `_camelCase`.

### Privacy — Non-Negotiable

This app is privacy-first by architecture, not by policy. These rules are
absolute and cannot be relaxed for convenience:

- **All data is encrypted at rest.** SQLCipher encrypts the database at the
  page level with AES-256 before anything touches disk. Plaintext never hits
  the filesystem.
- **Encryption keys never leave the device in plaintext.** Keys live in the
  platform secure enclave. Cross-device sync uses a wrapped key stored in
  Drive — never a raw key.
- **No plaintext data is ever transmitted to any server we control.** Drive
  sync uploads the encrypted `.db` file only.
- **No backend database.** We have no infrastructure that holds user data.
- **No analytics or telemetry that includes entry content.** Ever.
- **No third-party SDKs** that could access entry content (analytics, crash
  reporting, ads). If a crash reporter is needed, it must be fully sanitized.
- For BYOK AI features: entry text is sent to the user's chosen provider.
  This must be clearly disclosed before any entry content is transmitted.
- See [Storage & Encryption](docs/STORAGE.md) for full implementation details.
