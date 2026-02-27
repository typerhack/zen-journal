# Zen Journal — Onboarding

## Principle

The first three minutes decide whether someone becomes a daily journaler or
deletes the app. Onboarding must feel like the app itself — calm, purposeful,
unhurried. It is not a feature checklist. It is the user's first journaling
moment.

No progress bars. No "Step 2 of 6". No confetti. No aggressive permission
requests up front.

---

## Flow Overview

```
Launch
  → Welcome screen
  → Theme selection (system / light / dark)
  → Sign in with Google (for Drive sync)
  → Microphone permission  ← only if user taps [try voice]
  → Notification permission ← deferred to day 2
  → First entry
  → App
```

Permissions are requested **in context**, not upfront in a permission wall.

---

## Screen 1 — Welcome

A single, still screen. No animation on load — it simply appears.

```
[large, centred]

zen journal

A quiet place to meet yourself.

                          [begin]
```

- `displayLarge` for "zen journal" — DM Serif Display, warm near-black
- `bodyMedium` for the tagline — Inter, `onSurfaceMuted`
- `[begin]` is the only interactive element — `ZenButton`, accent colour
- Background: `surface` (#F7F3EE light / #18161A dark)
- No logo, no illustration, no version number

---

## Screen 2 — Sign In with Google

Brief, honest. No dark patterns around skipping.

```
[centred]

Your journal lives in your
Google Drive — private to you.

We cannot read your entries.
No account with us required.

[continue with Google]

[skip for now — entries stay on this device only]
```

- `[skip for now]` is clearly visible — not hidden in small print
- If skipped: app works fully locally, sync disabled, user can connect later
  in Settings
- On `[continue with Google]`: standard Google OAuth flow (system browser
  or native sheet)
- After auth: brief confirmation — `[ok] Connected to Google Drive` inline,
  not a modal

---

## Screen 3 — First Entry

Straight into writing. No tutorial, no feature tour. The app teaches itself
through use.

```
[top, small, muted]
Today, [day] [date]


[large, centred, display font]
What are you carrying
into this moment?


[text area — full width, minimal border]
_




[bottom]
[mic icon]  write or speak          [save]
```

- The prompt is the teacher — it models what journaling looks like
- The text area is focused automatically — keyboard appears
- `[mic icon]` is visible but not prominent — discovery, not instruction
- First tap of mic triggers the microphone permission request with context:
  `"Zen Journal would like to use your microphone to transcribe your voice
  into text. Your audio is processed on this device and never uploaded."`
- No "skip prompt" option on the first entry — the prompt is the onboarding

---

## What Happens After the First Save

After saving the first entry the user lands in the main journal view. No
celebration, no badge, no streak counter. Just their entry, quietly saved.

A single, gentle message appears inline below the entry — fades in after
1 second, fades out after 6 seconds:

```
[onSurfaceMuted, bodySmall, centred]
Your words are encrypted and saved.
```

That is the entire onboarding confirmation. Then silence.

---

## Notification Permission — Deferred to Day 2

The notification permission request is never shown during onboarding.

On the user's second day of use (or after their second entry, whichever
comes first), a single inline card appears at the top of the journal:

```
┌─────────────────────────────────────────┐
│  A gentle reminder?                     │
│  We can nudge you to write each day,    │
│  at a time you choose.                  │
│                                         │
│  [set a reminder]      [not for me]     │
└─────────────────────────────────────────┘
```

- `[not for me]` permanently dismisses this — never shown again
- `[set a reminder]` opens a time picker, then requests notification permission
  with context already established

---

## No Feature Tour

There is no walkthrough, tooltip sequence, or highlight tour. Features are
discovered naturally:

| Feature | Discovery moment |
|---|---|
| Voice input | Mic button visible on entry screen |
| AI reflection | `[reflect]` button appears after saving, if model available |
| Search | Search icon in journal list header |
| Themes | Settings — first item |
| Export | Settings — clearly listed |
| App lock | Settings — Privacy & Security |

If a feature requires a download (Gemma 2B) or a key (BYOK), the prompt
appears at the moment the user tries to use it — not before.

---

## Returning User — App Relaunch

If app lock is enabled: ZenLockScreen (see SECURITY.md).
If app lock is disabled: straight to journal list or today's entry.
No splash screen. No loading gate if local data is available.
