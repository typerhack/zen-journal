# Contributing to Zen Journal

Thank you for contributing. Please read this before opening a PR.

## Non-negotiable rules

- **No Material or Cupertino widgets.** All UI must be custom-built.
  See `docs/DESIGN_SYSTEM.md`.
- **No emojis** anywhere — UI, copy, code comments, commit messages.
- **No telemetry, analytics, or data transmission** we control.
  See `docs/STORAGE.md` and the Privacy rules in `CLAUDE.md`.
- All colors, sizes, and spacing must come from `ZenTheme` tokens.
  No hardcoded values.

## Before you start

For anything beyond a small bug fix, open an issue first to discuss
the approach. This avoids wasted effort on PRs that conflict with
the project direction.

## PR checklist

- [ ] `flutter analyze` passes with no warnings
- [ ] `dart format` applied (`dart format lib/ test/`)
- [ ] `flutter test` passes
- [ ] Accessibility checklist completed for any new widget
  (see `docs/ACCESSIBILITY.md`)
- [ ] Both zen (light) and dark themes tested
- [ ] No hardcoded color, size, or spacing values

## Translations

Add a new ARB file to `lib/l10n/` using the existing `app_en.arb` as
the source of truth. Filename format: `app_<locale>.arb` (e.g. `app_fr.arb`).

## AI model improvements

Fine-tuning improvements to DistilBERT or Gemma 2B are welcome. Open an
issue with your training details, dataset, and evaluation metrics before
submitting weights.

## Code of conduct

This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md).
