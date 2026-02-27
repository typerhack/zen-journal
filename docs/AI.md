# Zen Journal — AI Architecture

## Philosophy

AI in Zen Journal is a silent witness that occasionally speaks. It never
interrupts, never judges, never takes over. It helps the user see themselves
more clearly over time.

- AI speaks only when invited
- No real-time suggestions while writing
- No chatbot interface
- No unsolicited notifications
- Reflections are invitations, not instructions

---

## Architecture Overview

Three tiers, in order of priority:

```
Tier 1 — Always on (bundled, no download, no key)
└── DistilBERT fine-tuned (~66MB)
    Mood inference, theme extraction, pattern tagging

Tier 2 — Optional download (on-device, free, private)
└── Gemma 2B fine-tuned (~1.5GB)
    Written reflections, journaling prompts, weekly digest

Tier 3 — BYOK (user's own key, best quality)
└── OpenAI / Anthropic / OpenRouter / Ollama
    Overrides Tier 2 for all generative tasks if configured
```

The app works fully offline and for free with Tier 1 alone. Tier 2 and Tier 3
are progressive enhancements. The user is never blocked or nudged to upgrade.

---

## Tier 1 — DistilBERT (Bundled, Always Available)

### What it does

DistilBERT handles all **classification tasks** — no text generation, purely
analysis. These run silently after every entry save, no user action required.

| Task | Output | Usage |
|---|---|---|
| Mood inference | `calm / anxious / grateful / heavy / reflective / unclear` | Entry tag, emotional timeline |
| Theme extraction | Up to 3 tags per entry e.g. `work / relationships / self` | Pattern grouping |
| Sentiment trajectory | `improving / stable / declining` over a window of entries | Weekly digest input |

### Implementation

- **Model:** `distilbert-base-uncased` fine-tuned on journaling + emotion datasets
- **Size:** ~66MB — bundled inside the app, no download required
- **Inference:** `ONNX Runtime` via `flutter_onnxruntime` plugin
- **Runs on:** iOS, Android, macOS, Windows, Linux — CPU, no GPU needed
- **Latency:** < 200ms per entry on any modern device

### Fine-tuning Plan

- Base: `distilbert-base-uncased` from Hugging Face
- Datasets: `dair-ai/emotion`, `go_emotions`, synthetic journaling entries
- Method: standard fine-tuning (not LoRA — model is small enough)
- Output: exported to ONNX format, quantized INT8
- Training: Google Colab free tier is sufficient

---

## Tier 2 — Gemma 2B (Optional Download, On-Device)

### What it does

Gemma 2B handles all **generative tasks** — writing actual text the user reads.

| Task | Trigger |
|---|---|
| Post-entry reflection (2–4 sentences) | After saving, user taps [reflect] |
| Contextual journaling prompt | Before writing, user taps [prompt me] |
| Weekly digest | Automatic, once per week, opt-in |
| Pattern observation | User taps [what do you notice?] in history |

### Implementation

- **Model:** `gemma-2b-it` fine-tuned on journaling reflection data
- **Size:** ~1.5GB (quantized INT4)
- **Flutter:** `flutter_gemma` (Google's official plugin)
- **Acceleration:** Metal (iOS/macOS), Vulkan (Android), CPU fallback (Windows/Linux)
- **Download:** on first use of any generative feature (see below)

### Download Flow

```
1. User taps [reflect] or [prompt me] for the first time
2. One-time prompt shown:
   "Download the reflection model to get AI insights on your entries.
    This is a one-time 1.5GB download stored on your device."
   [Download]  [Not now]
3. Progress shown as a quiet linear bar — no percentage, no ETA
4. On complete: model is cached, feature activates immediately
5. Model persists until user explicitly deletes it from Settings
```

### Fine-tuning Plan

- Base: `google/gemma-2b-it` from Hugging Face
- Training data: mindfulness reflection examples, CBT reframe patterns,
  journaling prompt libraries, synthetic entry + reflection pairs
- Method: LoRA fine-tuning — runs on a single GPU or Google Colab A100
- Output: exported to GGUF (for llama.cpp fallback) and TFLite (for flutter_gemma)
- Goal: short, warm, non-prescriptive reflections in the app's tone

---

## Tier 3 — BYOK (Bring Your Own Key)

Users who want higher quality generative output can connect their own AI
provider. This completely replaces Tier 2 for generative tasks. Tier 1
(DistilBERT classification) always runs on-device regardless.

### Supported Providers

| Provider | Models | Notes |
|---|---|---|
| **OpenAI** | `gpt-4o`, `gpt-4o-mini` | Direct API, user's own key |
| **Anthropic** | `claude-sonnet-4-6`, `claude-haiku-4-5` | Direct API, user's own key |
| **OpenRouter** | Any model on OpenRouter | Single key, access to 100+ models |
| **Ollama** | Any locally installed model | Local endpoint, no key needed |

**OpenRouter** is particularly valuable for open-source users — one key gives
access to free-tier models (Llama 3, Mistral, Gemma) as well as premium models,
letting users choose their own cost/quality tradeoff.

**Ollama** is the best option for desktop power users — fully local, free,
no account needed, OpenAI-compatible API.

### Key Storage

API keys are stored **only in the device's secure enclave** via
`flutter_secure_storage`. They are never written to Google Drive, never
written to the SQLite database, and never transmitted to any server we
control.

```
flutter_secure_storage keys:
  "byok.provider"   → "openai" | "anthropic" | "openrouter" | "ollama"
  "byok.api_key"    → raw API key string (stored in Keychain/Keystore)
  "byok.model"      → selected model string
  "byok.ollama_url" → Ollama endpoint (default: http://localhost:11434)
```

**Non-sensitive AI settings** (provider name, model selection) are also
written to the SQLite `settings` table so they sync to Drive. The key
itself never goes to Drive or the DB — only the identifier of which
provider is active.

**Consequence:** API keys must be re-entered on each new device. This is
the correct trade-off — the alternative (syncing keys to Drive) would mean
a compromised Drive account exposes API credentials. Users should be told
this clearly when first entering a key:

```
Your API key is stored securely on this device only.
You will need to re-enter it if you set up a new device.
```

There is no mechanism to recover a BYOK key from the app. If the device's
secure storage is wiped, the key must be re-entered.

### Ollama Setup

Ollama runs a local server on `http://localhost:11434` with an OpenAI-compatible
API. On desktop platforms (macOS/Windows/Linux) the app detects if Ollama is
running and offers to use it automatically — no manual configuration needed.

---

## AiService Interface

A single interface abstracts all three tiers. The rest of the app never
knows which provider is active.

```dart
abstract class AiService {
  // Classification (always Tier 1 — DistilBERT, never overridden)
  Future<MoodTag> inferMood(String entryText);
  Future<List<ThemeTag>> extractThemes(String entryText);
  Future<SentimentTrajectory> analyzeTrajectory(List<String> recentEntries);

  // Generative (Tier 2 or Tier 3 depending on user config)
  Future<String> generateReflection(String entryText, List<String> recentContext);
  Future<String> generatePrompt(List<String> recentContext);
  Future<String> generateWeeklyDigest(List<JournalEntry> weekEntries);

  // Provider info
  AiProvider get activeProvider;
  bool get isGenerativeAvailable;
}

enum AiProvider { distilbert, gemma2b, openAi, anthropic, openRouter, ollama }
```

---

## Prompt Design (Generative Tasks)

All prompts follow the same principles regardless of provider:

**Reflection prompt:**
```
System:
You are a gentle reflection companion for a mindfulness journal app.
Offer a single brief observation (2–4 sentences) about what the user has written.
Do not give advice. Do not diagnose. Do not use lists or headers.
Reflect patterns, themes, and emotions with warmth and curiosity.
Never start your response with "I". Write in plain prose.

User: [entry text]
[optional: last 3 entries for context]
```

**Prompt generation:**
```
System:
Suggest one short, open journaling prompt (one sentence, ends with ?)
based on the user's recent entries. Make it specific and personal, not generic.
No preamble. Just the question.

User: [summary of recent themes/mood]
```

**Model config defaults (BYOK):**
- Max tokens: `200` for reflection, `60` for prompts, `400` for weekly digest
- Temperature: `0.7`
- No system-level memory beyond what's passed in the prompt

---

## Privacy Rules

- DistilBERT runs entirely on-device. Entry text never leaves the device for Tier 1.
- Gemma 2B runs entirely on-device. Entry text never leaves the device for Tier 2.
- For BYOK (Tier 3): entry text is sent to the user's chosen provider.
  This is clearly disclosed in onboarding and in the AI settings screen.
- We never proxy, log, or store any entry content on our servers.
- We have no servers in the data path.

---

## Settings Screen — AI Section

```
AI & Reflection

Reflection model
  [o] On-device (Gemma 2B)      ← default if downloaded
  [ ] Connect your own AI

  If "Connect your own AI" selected:
    Provider: [OpenAI ▾]
    API Key:  [__________________]
    Model:    [gpt-4o-mini ▾]

  For Ollama:
    Endpoint: [http://localhost:11434]
    Model:    [llama3.1 ▾]         ← auto-detected from running Ollama

Downloaded models
  Gemma 2B (1.5GB)  [delete]
  Voice model — tiny (75MB)  [delete]

Automatic reflection
  [toggle] After saving an entry

Weekly digest
  [toggle] Every Sunday morning
```

---

## What AI Will NOT Do

- Suggest edits or rewrites to user entries
- Respond in real-time while the user is writing
- Act as a chatbot or conversational interface
- Send unsolicited push notifications
- Store or transmit entry content through our infrastructure
- Make diagnostic or clinical observations
