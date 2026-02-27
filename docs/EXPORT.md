# Zen Journal — Data Export

## Principle

If we believe in user data ownership, export is not optional. Users must be
able to take everything they have written and leave — in open, human-readable
formats that do not require Zen Journal to open.

---

## Export Formats

### Markdown (default)

One `.md` file per entry. Human-readable, portable, works in any text editor,
GitHub, Obsidian, Notion, and hundreds of other tools.

```markdown
# 2026-02-27 — Morning

**Prompt:** What am I carrying today?

**Mood:** reflective
**Themes:** work, self

---

Lorem ipsum entry content here...

---

*Reflection: You've returned to the theme of uncertainty three times this
week. What might it be pointing toward?*
```

### JSON (full data)

A single `zen-journal-export.json` containing all entries with all fields —
including AI tags, mood history, reflections. Useful for importing into other
tools or re-importing into a future version of Zen Journal.

```json
{
  "exported_at": "2026-02-27T09:00:00Z",
  "version": "1.0",
  "entries": [
    {
      "id": "uuid",
      "created_at": "2026-02-27T08:30:00Z",
      "prompt": "What am I carrying today?",
      "body": "...",
      "mood": "reflective",
      "themes": ["work", "self"],
      "reflection": "...",
      "voice_transcript": "..."
    }
  ]
}
```

### PDF

A clean, printable document. Entries in chronological order, styled with the
zen type system. Good for archiving or printing a period of journaling.

**Flutter package:** `pdf` (dart pdf library) — renders entirely on-device,
no external service.

---

## Export Scope

Users can choose:
- **All entries** — complete history
- **Date range** — e.g. last 30 days, this year, custom range
- **By theme** — all entries tagged with a specific theme

---

## Export Destination

Via the platform's native share sheet / save dialog:
- Save to device Files
- Save to Google Drive (different folder from app data — user-accessible)
- Share to any app (Notes, email, AirDrop, etc.)

No upload to any server we control.

---

## Delete All Data

Available in Settings alongside Export. Before deletion:

1. Show a plain, calm confirmation — no aggressive warnings, no dark patterns
2. Clearly state what will be deleted (local database + Drive sync file)
3. Suggest exporting first with a direct `[export first]` link
4. Require a second deliberate tap to confirm
5. Delete local SQLite database, then delete Drive files
6. Return to onboarding screen

```
Delete all journal data?

This will permanently delete all your entries, moods, reflections,
and settings from this device and your Google Drive.
This cannot be undone.

[export first]          [delete everything]
```

Styled with `destructive` colour token on the confirm action only.
No countdown timers, no excessive friction — just one clear confirmation.
