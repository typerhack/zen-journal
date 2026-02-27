# Zen Journal — Storage, Encryption & Sync

## Privacy-First Principle

User data is private by design, not by policy. The app is architected so that
even we — the developers — cannot read user journal entries. There is no server
in the data path. Encryption happens on-device before anything is written to
disk or synced to the cloud.

---

## Storage Stack

```
┌─────────────────────────────────────────┐
│           Application Layer             │
└────────────────┬────────────────────────┘
                 │ reads / writes
┌────────────────▼────────────────────────┐
│     SQLCipher (Encrypted SQLite)        │
│     AES-256-CBC · Page-level encryption │
│     zen_journal.db (local device)       │
└────────────────┬────────────────────────┘
                 │ encrypted file synced
┌────────────────▼────────────────────────┐
│     Google Drive (appDataFolder)        │
│     Stores encrypted .db blob only      │
│     Google never sees plaintext         │
└─────────────────────────────────────────┘
```

---

## Encryption

### Database Encryption — SQLCipher

- **Algorithm:** AES-256-CBC with HMAC-SHA512 page authentication
- **Scope:** Entire database file — schema, content, metadata, indexes
- **Flutter package:** `sqlcipher_flutter_libs` + `sqflite` with SQLCipher build
- The plaintext database never touches disk. SQLCipher encrypts at the page
  level before writing, decrypts on read.

### Encryption Key Management

A 256-bit random key is generated on first launch using a cryptographically
secure random number generator. This key never leaves the device in plaintext.

**On-device storage:**
The key is stored in the platform's secure hardware enclave via
`flutter_secure_storage`:

| Platform | Storage |
|---|---|
| iOS | Keychain (Secure Enclave backed) |
| Android | Android Keystore (hardware-backed on supported devices) |
| macOS | Keychain |
| Windows | Windows Credential Manager (DPAPI) |
| Linux | Secret Service API (GNOME Keyring) / encrypted file fallback |

**Migration note:**
Early development used `SharedPreferences` as a temporary key store.
`KeyManager.getOrCreateDatabaseKey()` checks for a legacy key in
SharedPreferences on first access, moves it to secure storage, then
removes it from SharedPreferences. The database key itself does not
change during migration — only its storage location. New installs go
directly to secure storage.

**Cross-device key sync:**

The Google user ID is non-secret and publicly derivable — using it as HKDF
input provides no cryptographic protection. The wrapping key must be
secret-derived. Two paths are provided by platform:

**Path A — Same-platform devices (preferred, zero friction):**

| Platform pair | Mechanism |
|---|---|
| iPhone → iPad / new iPhone | iCloud Keychain sync — key syncs automatically via Apple's encrypted cloud |
| Android → Android | Android Keystore Backup API (Android 9+) — key backed up to Google's encrypted key backup |
| Mac → Mac | iCloud Keychain |
| Windows → Windows | Not available — falls back to Path B |
| Cross-platform (iOS → Android, etc.) | Falls back to Path B |

Path A requires no user action and exposes no key material to us or to Drive.

**Path B — Cross-platform or manual recovery (passphrase-based):**

When same-platform sync is unavailable or the user is setting up a new
platform, a recovery passphrase is required. The passphrase was set during
initial setup and is known only to the user.

```
Key wrapping for Drive (Path B):
1. User sets a recovery passphrase during first-time setup
2. App derives a wrapping key: Argon2id(passphrase, random_salt, m=64MB, t=3, p=4)
3. random_salt (32 bytes, CSPRNG) stored alongside wrapped key in Drive
4. Wrapped key = AES-256-GCM(wrapping_key, db_encryption_key)
5. Stored in Drive: appDataFolder/zen-journal/keystore.bin
   Format: [salt 32B][nonce 12B][wrapped_key 32B][tag 16B]

New device setup (Path B):
1. User signs in with Google on new device
2. App fetches keystore.bin from Drive
3. User enters recovery passphrase
4. App derives wrapping key: Argon2id(passphrase, salt_from_keystore)
5. App unwraps db_encryption_key via AES-256-GCM
6. App stores db_encryption_key in new device's secure enclave
7. App fetches encrypted zen_journal.db from Drive
8. Database unlocked — done
```

Argon2id is chosen over PBKDF2 because it is memory-hard — resistant to
GPU and ASIC brute-force attacks on the passphrase.

**Recovery passphrase rules:**
- Required during first-time setup — not optional if the user has Google sync enabled
- Minimum 10 characters, no maximum
- Never stored anywhere — not in Drive, not in the app, not in the enclave
- If lost: data on existing devices remains accessible via secure enclave.
  Drive backup becomes irrecoverable. This is clearly communicated.
- Passphrase change re-derives and re-uploads keystore.bin immediately

### Passphrase App Lock (separate from recovery passphrase)

The recovery passphrase protects key backup. The app lock passphrase
(see SECURITY.md) gates app access. These are two distinct concepts and
must not be conflated in the UI or in code.

---

## Local Database Schema

Database file: `zen_journal.db` (SQLCipher encrypted)

```sql
-- Core journal entries
CREATE TABLE entries (
    id          TEXT    PRIMARY KEY,          -- UUID v4
    created_at  INTEGER NOT NULL,             -- Unix timestamp (ms)
    updated_at  INTEGER NOT NULL,
    prompt      TEXT,                         -- Prompt shown before writing
    body        TEXT    NOT NULL DEFAULT '',  -- Entry content (plaintext inside encrypted DB)
    word_count  INTEGER NOT NULL DEFAULT 0
);

-- Voice transcripts (separate — may be large)
CREATE TABLE voice_transcripts (
    entry_id    TEXT    PRIMARY KEY REFERENCES entries(id) ON DELETE CASCADE,
    transcript  TEXT    NOT NULL,
    duration_ms INTEGER
);

-- AI-inferred mood per entry (DistilBERT output)
CREATE TABLE entry_moods (
    entry_id    TEXT    NOT NULL REFERENCES entries(id) ON DELETE CASCADE,
    mood        TEXT    NOT NULL,   -- calm | anxious | grateful | heavy | reflective | unclear
    confidence  REAL    NOT NULL
);

-- AI-extracted themes per entry
CREATE TABLE entry_themes (
    entry_id    TEXT    NOT NULL REFERENCES entries(id) ON DELETE CASCADE,
    theme       TEXT    NOT NULL,   -- work | relationships | self | health | etc.
    confidence  REAL    NOT NULL
);

-- AI-generated reflections
CREATE TABLE entry_reflections (
    entry_id    TEXT    PRIMARY KEY REFERENCES entries(id) ON DELETE CASCADE,
    reflection  TEXT    NOT NULL,
    provider    TEXT    NOT NULL,   -- gemma2b | openai | anthropic | openrouter | ollama
    generated_at INTEGER NOT NULL
);

-- App settings (non-sensitive — sensitive settings use flutter_secure_storage)
CREATE TABLE settings (
    key         TEXT    PRIMARY KEY,
    value       TEXT    NOT NULL
);
```

**Indexes:**
```sql
CREATE INDEX idx_entries_created_at ON entries(created_at DESC);
CREATE INDEX idx_entry_moods_entry   ON entry_moods(entry_id);
CREATE INDEX idx_entry_themes_entry  ON entry_themes(entry_id);
```

---

## Full-Text Search (FTS5)

### Android compatibility note

FTS5 is not compiled into Android's system SQLite on all devices and OEM
builds. The migration wraps FTS5 table and trigger creation in a try/catch —
if `no such module: fts5` is thrown, the error is logged and skipped. All
core entry tables are always created first, so saving and reading entries
works on every device regardless of FTS5 availability. Search will be fully
supported once the storage stack moves to the SQLCipher native layer (which
ships with FTS5 included).

### Database recovery

If a previous app run left the database in a broken state (e.g. a failed
migration that set no `user_version`), `ZenDatabase.open()` detects the
failure, deletes the corrupt file, and recreates it from scratch. This is
safe during development; once real user data exists, this behaviour must be
replaced with a proper repair path before shipping.



SQLite's built-in FTS5 extension enables fast, on-device full-text search
across all entry content. No external search library needed.

```sql
-- FTS5 virtual table — standalone (no content= link because searchable
-- content spans two tables: entries and voice_transcripts).
-- Maintained entirely via explicit triggers below.
CREATE VIRTUAL TABLE entries_fts USING fts5(
    entry_id UNINDEXED,   -- entries.id (used for join, not indexed)
    body,                 -- entries.body
    prompt,               -- entries.prompt
    transcript,           -- voice_transcripts.transcript (empty string if none)
    tokenize='unicode61 remove_diacritics 1'
);

-- ── entries triggers ──────────────────────────────────────────────────────

CREATE TRIGGER fts_entries_ai AFTER INSERT ON entries BEGIN
    INSERT INTO entries_fts(entry_id, body, prompt, transcript)
    VALUES (new.id, new.body, COALESCE(new.prompt, ''), '');
END;

CREATE TRIGGER fts_entries_ad AFTER DELETE ON entries BEGIN
    DELETE FROM entries_fts WHERE entry_id = old.id;
END;

CREATE TRIGGER fts_entries_au AFTER UPDATE OF body, prompt ON entries BEGIN
    DELETE FROM entries_fts WHERE entry_id = old.id;
    INSERT INTO entries_fts(entry_id, body, prompt, transcript)
    SELECT new.id, new.body, COALESCE(new.prompt, ''),
           COALESCE((SELECT transcript FROM voice_transcripts
                     WHERE entry_id = new.id), '');
END;

-- ── voice_transcripts triggers ────────────────────────────────────────────

CREATE TRIGGER fts_transcripts_ai AFTER INSERT ON voice_transcripts BEGIN
    -- Entry row already exists in FTS; update transcript column in-place
    DELETE FROM entries_fts WHERE entry_id = new.entry_id;
    INSERT INTO entries_fts(entry_id, body, prompt, transcript)
    SELECT e.id, e.body, COALESCE(e.prompt, ''), new.transcript
    FROM entries e WHERE e.id = new.entry_id;
END;

CREATE TRIGGER fts_transcripts_ad AFTER DELETE ON voice_transcripts BEGIN
    DELETE FROM entries_fts WHERE entry_id = old.entry_id;
    INSERT INTO entries_fts(entry_id, body, prompt, transcript)
    SELECT e.id, e.body, COALESCE(e.prompt, ''), ''
    FROM entries e WHERE e.id = old.entry_id;
END;

CREATE TRIGGER fts_transcripts_au AFTER UPDATE OF transcript ON voice_transcripts BEGIN
    DELETE FROM entries_fts WHERE entry_id = old.entry_id;
    INSERT INTO entries_fts(entry_id, body, prompt, transcript)
    SELECT e.id, e.body, COALESCE(e.prompt, ''), new.transcript
    FROM entries e WHERE e.id = new.entry_id;
END;
```

### Query examples

```sql
-- Simple keyword search
SELECT e.* FROM entries e
JOIN entries_fts fts ON e.id = fts.entry_id
WHERE entries_fts MATCH 'anxiety'
ORDER BY rank;

-- Phrase search
WHERE entries_fts MATCH '"feeling stuck"'

-- Prefix search (autocomplete)
WHERE entries_fts MATCH 'grat*'

-- Search with snippet highlighting
SELECT fts.entry_id,
       snippet(entries_fts, 1, '[', ']', '...', 15) AS excerpt
FROM entries_fts
WHERE entries_fts MATCH 'work'
ORDER BY rank;
```

### Search UX rules

- Search is always on-device — never sends query to any external service
- Results ranked by FTS5 `rank` (relevance) by default, toggleable to date
- Snippets show matched excerpt with surrounding context (~15 words)
- Matched terms are highlighted using `accent` colour token
- Search input is debounced 300ms — no query fires on every keystroke
- Empty query state shows recent entries (no search executed)
- Search scope: entry body, prompts, and voice transcripts

---

## Google Drive Sync

### What is synced

| File | Contents |
|---|---|
| `appDataFolder/zen-journal/zen_journal.db` | Encrypted database (full) |
| `appDataFolder/zen-journal/keystore.bin` | Wrapped encryption key |

Only two files. Simple, auditable.

### Sync Strategy

#### Write throttling

Uploading the full encrypted DB on every keystroke or save would cause
constant network churn and Drive rate-limit errors under normal use.

- Writes are batched: a debounced upload fires **30 seconds after the last
  local write**, not immediately on each save
- If the app backgrounds before the debounce fires, the upload is attempted
  immediately before backgrounding
- If offline, the upload is queued and attempted on next foreground with
  connectivity

#### Optimistic concurrency via Drive ETag

Device-local timestamps (`updated_at`) are unreliable across devices due to
clock skew — a device with a wrong clock wins every conflict regardless of
actual write order.

Drive's `ETag` / `headRevisionId` is the authoritative version signal:

```
Upload flow:
1. Store the ETag of the last successfully downloaded/uploaded DB
   in the local settings table as sync_etag
2. On upload: send If-Match: <sync_etag> header
3. Drive returns 200 → upload accepted, store new ETag as sync_etag
4. Drive returns 412 (Precondition Failed) → conflict detected, run
   conflict resolution before retrying

Download flow:
1. On app open, fetch Drive file metadata (HEAD request, cheap)
2. Compare remote headRevisionId to local sync_etag
3. If equal: local is current, no download needed
4. If different: conflict resolution (see below)
```

#### Conflict resolution

Conflicts occur when two devices write while both are offline, then sync.
Full DB replacement (last-upload-wins) would silently discard entries.

Instead:
1. Download the remote encrypted DB to a temporary file
2. Decrypt both the local and remote DB
3. Diff at the **entry level**: for each `entry.id` present in both,
   compare `updated_at` — keep the more recently modified version
4. For entries present in only one version, keep them unconditionally
5. Rebuild a merged DB, encrypt, upload with `If-Match: <etag_of_remote>`
6. If the merge upload itself conflicts (rare — another device wrote during
   merge), retry from step 1 (max 3 retries before surfacing `[sync failed]`)

This means the worst case is that two simultaneous edits to the **same
entry** on two offline devices keeps only the most recently modified
version. For a journaling app (append-heavy, rarely editing past entries)
this is an acceptable and honest trade-off.

**Offline:**
All reads and writes work fully offline against the local SQLite database.
Sync state is tracked in the `settings` table (`sync_etag`, `sync_pending`).
A subtle sync indicator is shown in Settings only — never as a banner.

---

## Data Model — Entry Lifecycle

```
User writes / speaks
        │
        ▼
Entry saved to SQLite (encrypted)
        │
        ├──▶ DistilBERT runs locally → mood + themes written to DB
        │
        ├──▶ Drive sync triggered (encrypted file uploaded)
        │
        └──▶ If AI reflection enabled:
                Gemma 2B / BYOK generates reflection → stored in DB
```

---

## What We Never Do

- No plaintext data written to disk at any point
- No plaintext data transmitted to any server we control
- No analytics, telemetry, or crash reporting that includes entry content
- No cloud database (Firestore, Supabase, etc.) that holds user data
- No server-side decryption — we have no key, we cannot decrypt
- No third-party SDKs with access to entry content
