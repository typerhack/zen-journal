# Zen Journal — Open Source

## License

**MIT License.**

Most permissive common license. Anyone can use, copy, modify, distribute,
and build on the code — including commercially — with no restrictions beyond
attribution. Correct choice for a journaling app where the goal is maximum
reach and community contribution, not protecting a business model.

Add the standard MIT `LICENSE` file at the root of the repository.

---

## Repository Structure

```
zen-journal-app/
├── LICENSE
├── CLAUDE.md
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   └── feature_request.md
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── workflows/
│       ├── ci.yml          # lint + test on every PR
│       └── release.yml     # build + publish on tag
├── docs/
│   └── *.md
├── lib/
└── test/
```

---

## CI/CD — GitHub Actions

Versioning and release-number rules are defined in
[`docs/VERSIONING.md`](VERSIONING.md).

### `ci.yml` — runs on every PR and push to `main`

```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - flutter analyze
      - dart format --check

  test:
    runs-on: ubuntu-latest
    steps:
      - flutter test

  build-android:
    runs-on: ubuntu-latest
    steps:
      - flutter build apk --release

  build-macos-silicon:
    runs-on: macos-latest
    steps:
      - flutter build macos --release

  build-macos-intel:
    runs-on: macos-15-intel
    steps:
      - flutter build macos --release

  build-ios:
    runs-on: macos-latest
    steps:
      - flutter build ios --release --no-codesign

  build-windows:
    runs-on: windows-latest
    steps:
      - flutter build windows --release

  build-linux-x64:
    runs-on: ubuntu-latest
    steps:
      - flutter build linux --release

  build-linux-arm64:
    runs-on: ubuntu-22.04-arm
    steps:
      - flutter build linux --release
```

### `release.yml` — runs on version tag (`v*.*.*`)

Builds release artifacts for all platforms and creates a GitHub Release:

| Platform | Artifact | Runner |
|---|---|---|
| Android | `.apk` + `.aab` | `ubuntu-latest` |
| iOS | `ios-runner.zip` (`Runner.app`) | `macos-latest` |
| macOS (Apple Silicon) | `macos-arm64.zip` (`.app`) | `macos-latest` |
| macOS (Intel) | `macos-x86_64.zip` (`.app`) | `macos-15-intel` |
| Windows (x64) | `windows-x64.zip` | `windows-latest` |
| Windows (ARM64) | `windows-arm64.zip` | `windows-11-arm` |
| Linux (x64) | `.deb` + `.rpm` + `.AppImage` | `ubuntu-22.04` |
| Linux (ARM64) | `.deb` + `.rpm` + `.AppImage` | `ubuntu-22.04-arm` |

All artifacts attached to the GitHub Release automatically.

---

## App Store Distribution

| Store | Platform | Cost | Notes |
|---|---|---|---|
| Google Play | Android | $25 one-time | Free app, no ads |
| Apple App Store | iOS + macOS | $99/year | Free app |
| Microsoft Store | Windows | Free | Optional |
| Flathub | Linux | Free | AppImage also distributed via GitHub Releases |
| GitHub Releases | All | Free | Primary distribution for Linux, fallback for all |

The app is free on all stores. No in-app purchases, no subscription,
no ads. The open-source nature means anyone can build from source.

---

## Contributing Guidelines (`CONTRIBUTING.md`)

Key sections to include:

- **Design rule:** All UI contributions must follow the design system.
  No Material widgets. No emojis. Custom widgets only.
- **Privacy rule:** No contribution may add telemetry, analytics, or
  any data transmission we control.
- **Language support:** Translation contributions are welcome. Add locale
  files to `lib/l10n/` following the existing structure.
- **Model improvements:** Fine-tuning improvements to DistilBERT or Gemma
  2B are welcome — submit the ONNX/weights file and training details.
- **PR checklist:** lint passes, tests pass, accessibility checklist
  completed for any new widget.

---

## Code of Conduct

Contributor Covenant v2.1 — the standard, widely recognised CoC.
Add as `CODE_OF_CONDUCT.md` at the root.

---

## Localization (i18n)

Flutter's built-in `flutter_localizations` + `intl` package.

All user-facing strings live in ARB files (`lib/l10n/`):
```
lib/l10n/
├── app_en.arb      # English (source of truth)
├── app_es.arb      # Spanish (community contributed)
└── app_*.arb       # other languages
```

Community members can contribute translations by adding a new ARB file.
No external translation service — strings are in the repository.
