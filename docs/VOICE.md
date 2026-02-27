# Zen Journal — Voice Input

## Overview

Users can speak their journal entry instead of typing. Audio is captured and
transcribed entirely **on-device** — no audio ever leaves the user's device.
The transcript is dropped into the editor where the user can review and edit
before saving.

On-device transcription is the right choice for this app:
- Journal entries are deeply personal — privacy is non-negotiable
- Works fully offline
- No API cost, no API key management
- No network latency for short recordings

## Platform Strategy

Each platform uses the best available on-device transcription engine:

| Platform | Engine | Notes |
|---|---|---|
| iOS 17+ | Apple `SFSpeechRecognizer` | Core ML optimized Whisper, near-zero overhead |
| macOS 14+ | Apple `SFSpeechRecognizer` | Same as iOS, excellent on Apple Silicon |
| Android | `whisper.cpp` (Flutter plugin) | `tiny` or `base` model — downloaded on first use |
| Windows | `whisper.cpp` (Flutter plugin) | `tiny` or `base` model — downloaded on first use |
| Linux | `whisper.cpp` (Flutter plugin) | `tiny` or `base` model — downloaded on first use |

A single `VoiceService` interface abstracts the platform difference — the rest
of the app never knows which engine is running.

```dart
abstract class VoiceService {
  Future<void> startRecording();
  Future<String> stopAndTranscribe();
  Stream<double> get amplitudeStream; // for waveform UI
  Future<bool> get isAvailable;
}
```

## whisper.cpp Integration

**Flutter plugin:** `whisper_flutter_new`

### Model Selection

| Model | Size | Use case |
|---|---|---|
| `tiny` | ~75MB | Default — fast, accurate enough for clear journal speech |
| `base` | ~145MB | Optional upgrade for users who want better accuracy |

The `tiny` model is the default. Journal entries are short (1–5 min), one
speaker, clear speech — `tiny` handles this well. The `base` model can be
offered as an in-app setting for users who prefer it.

### Model Bundling

Models are not bundled in the initial app download — this keeps the app store
size small. On first use of voice input:

```
1. User taps mic for the first time
2. App shows a one-time download prompt:
   "To transcribe offline, download the voice model (75MB)"
3. Model downloads to app documents directory
4. Model is cached — never downloaded again
5. Recording begins
```

Model files are stored in the app's documents directory and persisted across
sessions. The `base` model can be downloaded optionally from settings.

### Audio Format

- Format: 16-bit PCM WAV, 16kHz mono (whisper.cpp native format)
- Flutter recording: `record` package captures audio and converts as needed

## Flow

```
1. User taps mic button
2. First time: trigger model download if not cached
3. Request microphone permission if not granted
4. Recording starts — waveform animation begins
5. User taps stop OR silence detection triggers auto-stop
6. whisper.cpp / SFSpeechRecognizer transcribes audio locally
7. Transcript inserted into editor
8. User reviews and edits if needed, then saves
```

## UX Rules

- The mic button uses a slow, breathing pulse animation while recording —
  calm, not urgent. Use the accent color (`sage green`), never red.
- Show a live waveform (amplitude visualization) during recording so the user
  knows audio is being captured.
- During transcription show a subtle loading state on the editor — a soft
  shimmer on the text area, not a spinner.
- If transcription fails, show inline error text below the editor — never a
  toast or modal.
- User can cancel recording at any time with no side effects.
- Model download progress is shown as a simple linear progress indicator with
  a plain text label ("Downloading voice model…"). No percentages.

## Silence Detection

Auto-stop recording after 2.5 seconds of silence (amplitude below threshold).
This prevents orphaned recordings when the user forgets to tap stop.
The threshold and duration are configurable constants, not hardcoded.

## Settings

Expose in the Settings screen:
- **Voice model:** Tiny (default) / Base — with size labels
- **Auto-stop silence:** On (default) / Off
- **Delete downloaded model** — frees storage if user no longer wants voice input
