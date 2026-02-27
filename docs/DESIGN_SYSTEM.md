# Zen Journal — Design System

## Philosophy

The design system exists to serve one purpose: to make the user feel calm,
focused, and unhurried. Every decision — color, spacing, type size, animation
duration — is made in service of that feeling.

**Zen principles that drive every decision:**

- **Ma (間) — negative space.** Emptiness is not absence. Whitespace is a primary
  design element that gives content room to breathe.
- **Wabi-sabi.** Imperfection and simplicity over polish and complexity. Avoid
  decorative elements that don't serve the content.
- **Kanso — simplicity.** If something can be removed without losing meaning,
  remove it.
- **Seijaku — stillness.** Animations should never startle. The interface should
  feel like a calm lake, not a busy street.

---

## Themes

There are exactly two themes: **Zen** (light) and **Dark**. The app detects
`Brightness.light / Brightness.dark` from the system and applies the correct
theme automatically. The user can override manually; the preference is persisted
locally.

All theme values are accessed via `ZenTheme.of(context)` — a custom
`InheritedWidget`. Never use `Theme.of(context)` or `MaterialTheme`.

---

## Color Tokens

### Zen (Light) Theme

| Token | Hex | Usage |
|---|---|---|
| `surface` | `#F7F3EE` | App background — warm off-white, like aged paper |
| `surfaceElevated` | `#F0EAE2` | Cards, input areas — slightly deeper |
| `surfaceSunken` | `#E8E0D5` | Pressed states, secondary containers |
| `onSurface` | `#2A2520` | Primary text — warm near-black, never pure black |
| `onSurfaceMuted` | `#7A6F65` | Secondary text, timestamps, placeholders |
| `onSurfaceFaint` | `#B8AFA6` | Disabled states, dividers |
| `accent` | `#7B9E87` | Muted sage green — the one accent color |
| `accentMuted` | `#A8BFB0` | Accent on hover, light accent fills |
| `accentFaint` | `#D6E4DA` | Accent background tints |
| `destructive` | `#B5746A` | Delete, error — muted terracotta, never harsh red |

### Dark Theme

| Token | Hex | Usage |
|---|---|---|
| `surface` | `#18161A` | Deep charcoal — not pure black |
| `surfaceElevated` | `#211E24` | Cards, input areas |
| `surfaceSunken` | `#141216` | Pressed states |
| `onSurface` | `#EDE9E4` | Primary text — warm off-white |
| `onSurfaceMuted` | `#8A8485` | Secondary text, timestamps |
| `onSurfaceFaint` | `#4A4448` | Dividers, disabled |
| `accent` | `#7B9E87` | Same sage — consistent across themes |
| `accentMuted` | `#5A7A66` | Darker accent for dark theme |
| `accentFaint` | `#243028` | Accent background tints |
| `destructive` | `#B5746A` | Same muted terracotta |

**Rules:**
- Never add a new color without a clear semantic purpose.
- Never use a hex value directly in a widget. Always use a `ZenTheme` token.
- The accent color is used sparingly — active state indicators, CTAs, progress.
  It should feel like a small reward, not wallpaper.

---

## Typography

### Fonts

| Role | Font | Weight |
|---|---|---|
| Display / Hero | `DM Serif Display` | Regular (400) |
| Heading | `DM Serif Display` | Regular (400) |
| Body | `Inter` | Regular (400), Medium (500) |
| Caption / Meta | `Inter` | Regular (400) |
| Monospace | `JetBrains Mono` | Regular (400) |

### Type Scale

All sizes in logical pixels. Line heights are unitless multipliers.

| Token | Size | Line Height | Usage |
|---|---|---|---|
| `displayLarge` | 40 | 1.2 | Hero moments, date headers |
| `displaySmall` | 28 | 1.3 | Section titles |
| `headingLarge` | 22 | 1.4 | Page titles |
| `headingSmall` | 18 | 1.4 | Card titles, prompts |
| `bodyLarge` | 16 | 1.6 | Journal entry body text |
| `bodyMedium` | 14 | 1.6 | UI labels, descriptions |
| `bodySmall` | 12 | 1.5 | Timestamps, metadata |
| `caption` | 11 | 1.4 | Badges, tags |

**Rules:**
- Body text (`bodyLarge`) for journal content always uses `1.6` line height —
  generous leading makes reading feel unhurried.
- Never use bold weight for body text. Emphasis is conveyed through size and
  color contrast, not weight.
- Letter spacing on display text: `+0.5` to `+1.0` logical pixels. On body: `0`.

---

## Spacing

4-point base grid. All spacing values are multiples of 4.

| Token | Value | Usage |
|---|---|---|
| `space2` | 2px | Micro gaps (icon to label) |
| `space4` | 4px | Tight internal padding |
| `space8` | 8px | Small gaps between related elements |
| `space12` | 12px | Default internal padding |
| `space16` | 16px | Standard padding, list item vertical space |
| `space24` | 24px | Section gaps, card padding |
| `space32` | 32px | Large section separation |
| `space48` | 48px | Hero spacing, breathing room |
| `space64` | 64px | Full-section breaks |

**Page margins:** `space24` on mobile, `space48` on tablet/desktop.

---

## Border Radius

| Token | Value | Usage |
|---|---|---|
| `radiusSmall` | 6px | Small chips, tags |
| `radiusMedium` | 12px | Cards, input fields |
| `radiusLarge` | 20px | Bottom sheets, modals |
| `radiusFull` | 999px | Pills, avatar containers |

---

## Elevation & Shadows

No hard drop shadows. Elevation is expressed through **background color layering**
using the surface tokens (`surface`, `surfaceElevated`, `surfaceSunken`).

The rare exception: a very soft, diffused shadow on floating elements:
```
BoxShadow(
  color: Color(0x0A000000),  // 4% black
  blurRadius: 24,
  offset: Offset(0, 8),
)
```

Never use shadows with sharp edges or high opacity.

---

## Animation

**Philosophy:** The interface breathes. Nothing snaps. Nothing races.

### Timing

| Token | Duration | Usage |
|---|---|---|
| `durationFast` | 150ms | Micro-interactions (button press, checkbox) |
| `durationNormal` | 250ms | Most UI transitions (fade, color change) |
| `durationSlow` | 400ms | Panel open/close, card expansion |
| `durationPage` | 600ms | Page/route transitions |

### Easing

| Token | Curve | Usage |
|---|---|---|
| `easeDefault` | `Curves.easeInOut` | Default for all transitions |
| `easeEnter` | `Curves.easeOut` | Elements entering the screen |
| `easeExit` | `Curves.easeIn` | Elements leaving the screen |
| `easeSpring` | `Curves.elasticOut` (damping 0.8) | Playful moments only — use rarely |

**Rules:**
- Never use `Curves.linear`. It feels mechanical.
- Page transitions: fade + subtle vertical translate (8px upward on enter).
- Interactive elements respond within `durationFast` — the UI must feel alive.
- Do not animate more than 2 properties simultaneously on the same widget.

---

## Accessibility

Every custom widget must be accessible by design. Full rules, contrast
verification tables, and a per-widget checklist live in
[Accessibility](ACCESSIBILITY.md).

Summary of non-negotiables:
- Every interactive widget has a `Semantics` wrapper with correct properties
- Touch targets are minimum 48×48 logical pixels
- All text respects system font scaling — never override `textScaleFactor`
- `MediaQuery.disableAnimations` is respected — all animations collapse to
  `Duration.zero` when reduced motion is enabled
- Focus indicators are visible (2px accent ring) on desktop / keyboard nav
- Contrast ratios meet WCAG 2.1 AA for all text in both themes

---

## Custom Widget Rules

### Non-negotiable

- **No Material or Cupertino widgets.** Not even as a base class. Start from
  `StatelessWidget`, `StatefulWidget`, or `CustomPainter`.
- Every interactive widget must implement all states: default, hovered, pressed,
  focused, disabled.
- Every widget reads colors and text styles from `ZenTheme.of(context)` only.

### Building a New Widget

1. Create the file in `lib/ui/components/`.
2. The widget takes only the data it needs — no god objects.
3. Implement `_buildDefault()`, and explicitly handle hover/press/disabled states.
4. Animate state changes using `AnimatedContainer` or explicit `AnimationController`.
5. Write a visual comment block at the top explaining the widget's zen purpose.

### Example Pattern

```dart
// ZenButton — a minimal, touch-responsive action element.
// Conveys action through subtle surface shift and opacity, never heavy borders.
class ZenButton extends StatefulWidget {
  const ZenButton({
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.isDisabled = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isDisabled;

  @override
  State<ZenButton> createState() => _ZenButtonState();
}

class _ZenButtonState extends State<ZenButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = ZenTheme.of(context);
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.isDisabled ? null : widget.onTap,
      child: AnimatedContainer(
        duration: theme.durationFast,
        curve: theme.easeDefault,
        padding: EdgeInsets.symmetric(
          horizontal: theme.space24,
          vertical: theme.space12,
        ),
        decoration: BoxDecoration(
          color: _pressed
              ? theme.colors.surfaceSunken
              : theme.colors.surfaceElevated,
          borderRadius: BorderRadius.circular(theme.radiusMedium),
        ),
        child: Text(
          widget.label,
          style: theme.text.bodyMedium.copyWith(
            color: widget.isDisabled
                ? theme.colors.onSurfaceFaint
                : widget.isDestructive
                    ? theme.colors.destructive
                    : theme.colors.onSurface,
          ),
        ),
      ),
    );
  }
}
```

---

## Iconography

Icons are allowed and encouraged where they aid clarity. Emojis are not.

### Allowed
- SVG icon libraries (e.g. `Lucide`, `Phosphor Icons`, `Tabler Icons`) rendered
  via `flutter_svg` or a custom icon font
- Status indicators using text labels in brackets: `[ok]` `[success]` `[failed]`
  `[warning]` `[pending]` — styled with the appropriate color token
- Custom `CustomPainter` icons hand-drawn to match the zen aesthetic

### Prohibited
- **Emojis — anywhere, without exception.** Not in UI, not in copy, not in
  code comments, not in error messages, not in onboarding. Emojis break the
  visual tone and cannot be styled to match the design system.
- Platform default icons (`Icons.*` from Material, `CupertinoIcons.*`)
- Icon-only interactive elements on primary navigation (always pair with a label)

### Icon Style Rules
- Stroke weight: 1.5px — thin enough to feel light, heavy enough to read small
- Size: align to the 4pt grid (`16`, `20`, `24`, `32`)
- Color: always use a `ZenTheme` color token — never hardcode
- Active/selected state: use `accent` color, not a filled variant

---

## What We Never Do

- No emojis — anywhere, in any context.
- No gradients (except extremely subtle, single-hue surface gradients if needed).
- No rounded corners above `radiusLarge` on content containers.
- No more than one accent color in a single view.
- No loading spinners — use skeleton placeholders that match the content shape.
- No toast notifications that pop from the bottom. Use inline feedback.
- No modals with heavy chrome (title bar + button row). Keep overlays minimal.
- No icons without text labels on primary navigation.
- No animations that delay user interaction.
- No Material (`Icons.*`) or Cupertino (`CupertinoIcons.*`) icon sets.
