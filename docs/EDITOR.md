# Zen Journal — Editor

## Approach

Markdown with live preview. The user writes Markdown syntax and it renders
immediately as formatted text. Power users get structure and emphasis;
beginners who never learn Markdown get a clean writing experience since
plain prose renders identically.

No toolbar. No formatting buttons. The writing surface is uninterrupted.

---

## Flutter Package

**`flutter_markdown`** for rendering — official Flutter team package,
actively maintained, renders CommonMark spec Markdown.

The editor is built on **`EditableText`** directly — the low-level Flutter
foundation widget that `TextField` wraps internally. `TextField` itself is
a Material widget and is prohibited by our widget rules.

`ZenEditor` is a custom `StatefulWidget` that composes:
- `EditableText` — handles raw text input, cursor, selection, IME
- A custom `TextSpan` tree built by a Markdown span parser — renders
  formatted output inline as the user types
- `flutter_markdown` — used only for the read-only entry detail view,
  not inside the editor itself

```dart
// ZenEditor — custom EditableText-based markdown editor.
// Parses markdown spans inline and renders styled TextSpan tree.
// No Material widgets used.
class ZenEditor extends StatefulWidget {
  const ZenEditor({
    required this.controller,
    required this.focusNode,
    this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;

  @override
  State<ZenEditor> createState() => _ZenEditorState();
}

class _ZenEditorState extends State<ZenEditor> {
  @override
  Widget build(BuildContext context) {
    final theme = ZenTheme.of(context);
    return EditableText(
      controller: widget.controller,
      focusNode: widget.focusNode,
      style: theme.text.bodyLarge,
      cursorColor: theme.colors.accent,
      backgroundCursorColor: theme.colors.surfaceElevated,
      selectionColor: theme.colors.accentFaint,
      strutStyle: StrutStyle(height: 1.6),
      maxLines: null,        // multiline, unbounded
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      onChanged: widget.onChanged,
    );
  }
}
```

The Markdown span parser runs on `onChanged` and rebuilds the `TextSpan`
tree — bold, italic, headings, blockquotes — without replacing the raw
text in the controller.

---

## Supported Markdown Syntax

A deliberate subset — enough for expression, not so much it becomes a
formatting tool:

| Syntax | Output | Use case |
|---|---|---|
| `**bold**` | **bold** | Emphasis on a key word or feeling |
| `_italic_` | _italic_ | Gentle emphasis, titles, foreign words |
| `## Heading` | Large heading | Section breaks within a long entry |
| `### Subheading` | Medium heading | Nested sections |
| `- item` | Bullet list | Lists of thoughts, gratitudes |
| `> quote` | Blockquote | A meaningful quote or recalled dialogue |
| `---` | Divider line | Separating sections of an entry |

**Not supported** (intentionally excluded — keeps the editor focused):
- Tables
- Code blocks
- Images / attachments
- Footnotes
- HTML

---

## Editor UX

```
┌─────────────────────────────────────────────┐
│  Friday, 27 February                        │
│  ─────────────────────────                  │
│  What am I carrying today?                  │
│  ─────────────────────────                  │
│                                             │
│  I woke up feeling heavy. The               │
│  meeting yesterday stayed with me.          │
│                                             │
│  A realisation                              │
│  ──────────────────                         │
│  Maybe it is not about the meeting          │
│  at all.                                    │
│                                             │
│                          [mic]       [save] │
└─────────────────────────────────────────────┘
```

- The prompt is displayed above the entry in `headingSmall`, `onSurfaceMuted`
- A subtle divider separates prompt from entry body
- Cursor is placed at the start of the body on open
- Keyboard appears automatically on new entry
- `[save]` is always visible — never requires scrolling to reach
- `[mic]` sits beside save — quiet, accessible, not dominant
- No word count, no character count visible while writing (available in
  entry detail after saving)
- No autosave indicator — saving is explicit via `[save]`

---

## Typography in the Editor

Rendered Markdown uses the standard type scale from the design system:

| Element | Style |
|---|---|
| Body / paragraph | `bodyLarge` — Inter 16px, line height 1.6 |
| `## Heading` | `headingLarge` — DM Serif Display 22px |
| `### Subheading` | `headingSmall` — DM Serif Display 18px |
| `**bold**` | `bodyLarge` + `FontWeight.w600` |
| `_italic_` | `bodyLarge` + `FontStyle.italic` |
| `> blockquote` | `bodyLarge` + `onSurfaceMuted` + left accent border |
| `- bullet` | `bodyLarge` + custom bullet (filled circle, `accent` colour, 4px) |
| `---` divider | 1px `onSurfaceFaint` line, `space16` vertical margin |

---

## Syntax Hint — First Entry Only

On the very first entry, a single dismissible line appears below the cursor
in `onSurfaceFaint`:

```
tip: **bold**  _italic_  ## heading  > quote
```

It disappears on first keypress and never appears again.
No modal, no tooltip, no tutorial.

---

## Accessibility in the Editor

- The editing area has `Semantics(label: 'Journal entry', textField: true, multiline: true)`
- Rendered Markdown has correct heading semantics (`header: true` on heading spans)
- Blockquotes are announced as quotes by screen readers
- Font scaling is fully respected — editor reflows at all text sizes
- The `[save]` button remains reachable at all font scale levels
