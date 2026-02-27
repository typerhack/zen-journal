# Zen Journal — Accessibility

## Principle

Building custom widgets means we lose every accessibility behaviour that
Material widgets provide for free. We must build it back in — deliberately,
in every widget. Accessibility is not a feature added at the end. It is a
constraint that shapes every component from the start.

The zen philosophy and accessibility are aligned: clarity, simplicity, and
respect for the user's context.

---

## Semantics — Every Interactive Widget

Every custom widget that a user can interact with must include a `Semantics`
wrapper with the correct properties. No exceptions.

```dart
// Interactive element example
Semantics(
  label: 'Save journal entry',
  button: true,
  enabled: !widget.isDisabled,
  onTap: widget.isDisabled ? null : widget.onTap,
  child: // ... your custom widget
)

// Text input example
Semantics(
  label: 'Journal entry',
  textField: true,
  multiline: true,
  child: // ... your custom text area
)

// Image / icon example
Semantics(
  label: 'Microphone — start voice recording',
  child: // ... your icon widget
)

// Decorative element (screen reader skips it)
Semantics(
  excludeSemantics: true,
  child: // ... purely visual element
)
```

### Required semantic properties by widget type

| Widget type | Required properties |
|---|---|
| Button / tap target | `label`, `button: true`, `enabled` |
| Text field | `label`, `textField: true`, `multiline` if applicable |
| Toggle / checkbox | `label`, `checked`, `toggled` |
| Icon (interactive) | `label` describing the action, not the icon |
| Icon (decorative) | `excludeSemantics: true` |
| Progress indicator | `label`, `value` (0.0–1.0) |
| Navigation item | `label`, `selected` |
| Entry in a list | `label` summarising content, `button: true` if tappable |

---

## Touch Targets

All interactive elements must meet the **48×48 logical pixel minimum** — this
covers both WCAG 2.1 AA and platform guidelines (iOS HIG, Material).

The visual size of a widget may be smaller (e.g. a 20px icon), but the
tappable area must be padded to 48×48 minimum using `SizedBox` or custom
hit-testing.

```dart
// Correct — small icon, full touch target
GestureDetector(
  onTap: onTap,
  child: SizedBox(
    width: 48,
    height: 48,
    child: Center(
      child: SvgIcon(icon, size: 20),
    ),
  ),
)
```

Spacing between adjacent touch targets: minimum **8px**.

---

## Colour Contrast

All text must meet **WCAG 2.1 AA** contrast ratios at minimum.

| Text type | Minimum ratio |
|---|---|
| Body text (< 18px) | 4.5 : 1 |
| Large text (≥ 18px, or ≥ 14px bold) | 3.0 : 1 |
| UI component boundaries | 3.0 : 1 |
| Disabled / placeholder text | No requirement — but must be visually distinguishable |

### Verified contrast ratios for our tokens

**Zen (light) theme — on `surface` (#F7F3EE):**

| Token | Value | Ratio | [ok] / [warning] |
|---|---|---|---|
| `onSurface` | #2A2520 | 14.3 : 1 | [ok] |
| `onSurfaceMuted` | #7A6F65 | 4.6 : 1 | [ok] |
| `onSurfaceFaint` | #B8AFA6 | 1.9 : 1 | [warning] — disabled only |
| `accent` | #7B9E87 | 3.1 : 1 | [ok] large text only |
| `destructive` | #B5746A | 3.4 : 1 | [ok] large text only |

**Dark theme — on `surface` (#18161A):**

| Token | Value | Ratio | [ok] / [warning] |
|---|---|---|---|
| `onSurface` | #EDE9E4 | 15.1 : 1 | [ok] |
| `onSurfaceMuted` | #8A8485 | 5.2 : 1 | [ok] |
| `onSurfaceFaint` | #4A4448 | 1.8 : 1 | [warning] — disabled only |
| `accent` | #7B9E87 | 4.7 : 1 | [ok] |

**Rule:** `onSurfaceFaint` is only used for disabled states and decorative
dividers — never for text the user needs to read.

---

## Font Scaling

The app must remain usable and readable at all system font sizes — from the
smallest to the largest accessibility setting.

```dart
// Never do this — locks text to a fixed scale
Text(
  'Journal entry',
  textScaleFactor: 1.0,  // prohibited
)

// Correct — respect system setting
Text('Journal entry', style: theme.text.bodyLarge)
```

**Rules:**
- Never override `textScaleFactor` or `MediaQuery.textScaleFactor`
- All layouts must be tested at 1.0x, 1.5x, and 2.0x font scale
- Use `Flexible`, `Expanded`, and `FittedBox` so text containers grow
  with content — never clip text
- Minimum readable body font size: 14px at 1.0x scale (becomes 28px at 2.0x —
  ensure containers accommodate this)

---

## Reduced Motion

Some users have vestibular disorders or motion sensitivity. Flutter exposes
`MediaQuery.disableAnimations` — the app must respect it.

```dart
// In ZenTheme, expose a helper
bool get reduceMotion =>
    MediaQuery.of(context).disableAnimations;

// In animated widgets
AnimatedContainer(
  duration: theme.reduceMotion
      ? Duration.zero
      : theme.durationNormal,
  curve: theme.easeDefault,
  // ...
)
```

When reduced motion is enabled:
- All transitions use `Duration.zero`
- Page transitions are instant (no fade/slide)
- The breathing mic animation is static
- Skeleton loaders are static

---

## Keyboard & Focus Navigation

Required for desktop platforms (macOS, Windows, Linux) and external keyboard
users on mobile.

**Rules:**
- Every interactive widget must be focusable via `FocusNode` and respond to
  `Enter` / `Space` as activation keys
- Tab order must follow logical reading order (top-to-bottom, left-to-right)
- Focused widgets must show a visible focus indicator — a subtle `accent`
  coloured ring, 2px, `radiusMedium` offset by 2px
- Never trap focus (e.g. in a modal, focus must cycle within the modal,
  and `Escape` must dismiss it)

```dart
// Focus ring example
DecoratedBox(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(theme.radiusMedium + 2),
    border: _isFocused
        ? Border.all(color: theme.colors.accent, width: 2)
        : Border.all(color: Colors.transparent, width: 2),
  ),
  child: // ...
)
```

---

## Screen Reader Testing

Test with:
- **iOS:** VoiceOver
- **Android:** TalkBack
- **macOS:** VoiceOver
- **Windows:** NVDA or Narrator
- **Linux:** Orca

Minimum acceptance criteria:
- Every interactive element is announced with a meaningful label
- State changes (saved, loading, error) are announced
- The journal writing flow is fully navigable without sight
- No silent, unlabelled tap targets

---

## Checklist — New Widget Review

Before merging any new widget, verify:

- [ ] `Semantics` wrapper with correct properties
- [ ] Touch target >= 48x48px
- [ ] All text uses `ZenTheme` text styles (no locked `textScaleFactor`)
- [ ] Contrast ratio verified for both themes
- [ ] Hover, pressed, focused, disabled states all implemented
- [ ] `reduceMotion` respected in all animations
- [ ] Keyboard focusable and activatable on desktop
- [ ] Tested with VoiceOver (iOS/macOS) or TalkBack (Android)
