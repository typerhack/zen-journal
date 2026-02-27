# Zen Journal — Journaling Prompts Library

## Principle

A built-in library of curated prompts that works with zero AI, zero
download, zero internet connection. These are the foundation — the AI
generates contextual prompts on top of this library, not instead of it.

A good prompt opens a door without telling the user what they will find
on the other side.

---

## Prompt Selection

On new entry creation, one prompt is selected and shown. Selection logic:

```
1. If AI (Gemma 2B or BYOK) is available and user has > 3 entries:
     → AI generates a contextual prompt based on recent patterns
2. Otherwise:
     → Select from built-in library (time-aware, not recently shown)
```

The user can always tap `[different prompt]` to cycle to another — up to
3 times per session. After that, the prompt area is replaced with a blank
invitation to write freely.

---

## Built-In Prompt Library

### Morning (06:00 – 11:00)

```
What are you carrying into this moment?
What do you want to feel by the end of today?
What is one thing you are grateful for right now?
What would make today feel meaningful?
What are you hoping for today?
What does your body feel like this morning?
What is the first thing on your mind?
Who or what needs your attention today?
Is there anything you want to let go of before the day begins?
What would a good day look like?
```

### Evening (17:00 – 23:00)

```
What stayed with you today?
Where did you feel most like yourself today?
What surprised you?
What did you learn — about yourself or the world?
What was harder than expected? What was easier?
What are you taking into tomorrow?
Where did your energy go today?
What do you wish you had done differently?
What are you grateful for from today?
Is there something left unsaid that needs to go somewhere?
```

### Midday / Default (11:00 – 17:00)

```
What is on your mind right now?
What are you feeling beneath the surface?
What has been weighing on you lately?
What do you keep returning to?
What does this moment need from you?
What are you avoiding — and why might that be?
What would you tell a good friend in your situation?
What is true right now, even if it is uncomfortable?
What do you need that you are not asking for?
What would it mean to be kind to yourself today?
```

### Themed — Gratitude

```
What three things are you genuinely grateful for, and why?
Who has shown up for you recently?
What ordinary thing do you take for granted that you are glad exists?
What has gotten easier that used to be hard?
What about your life would your past self be relieved to know?
```

### Themed — Reflection (for weekly / longer pauses)

```
What patterns have you noticed in yourself lately?
What belief are you holding that might not be serving you?
What has changed in you over the last few months?
What are you still carrying that you could put down?
What would you do if you were not afraid?
What does a life well-lived look like to you?
What are you becoming?
```

---

## Prompt Rotation Rules

- Track recently shown prompt IDs in the database (last 30 shown)
- Never show the same prompt twice within 30 entries
- Time-aware selection: morning / midday / evening pools are used by
  time of day. If outside those windows, use the midday / default pool.
- Themed prompts (gratitude, reflection) are surfaced at most once per week
  and only in the morning or evening windows

---

## Adding Community Prompts

The prompt library is a simple Dart constant file — easy for contributors
to extend:

```dart
// lib/core/prompts/prompt_library.dart
class PromptLibrary {
  static const List<Prompt> morning = [ ... ];
  static const List<Prompt> evening = [ ... ];
  static const List<Prompt> default_ = [ ... ];
  static const List<Prompt> gratitude = [ ... ];
  static const List<Prompt> reflection = [ ... ];
}
```

Community submissions: a prompt must be:
- A single open question
- Emotionally open — not prescriptive or assuming a state
- Free of advice, suggestions, or implied "correct" answers
- Under 12 words

---

## Free Write Option

The user can always dismiss the prompt entirely. Tapping `[write freely]`
clears the prompt area and presents a blank entry with no prompt stored.
Free write entries are tagged as such in the database (`prompt: null`).
