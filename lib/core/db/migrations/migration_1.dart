import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

Future<void> applyMigration1(Database db) async {
  await db.execute('''
CREATE TABLE IF NOT EXISTS entries (
  id TEXT PRIMARY KEY,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  prompt TEXT,
  body TEXT NOT NULL DEFAULT '',
  word_count INTEGER NOT NULL DEFAULT 0
)
''');

  await db.execute('''
CREATE TABLE IF NOT EXISTS voice_transcripts (
  entry_id TEXT PRIMARY KEY REFERENCES entries(id) ON DELETE CASCADE,
  transcript TEXT NOT NULL,
  duration_ms INTEGER
)
''');

  await db.execute('''
CREATE TABLE IF NOT EXISTS entry_moods (
  entry_id TEXT NOT NULL REFERENCES entries(id) ON DELETE CASCADE,
  mood TEXT NOT NULL,
  confidence REAL NOT NULL
)
''');

  await db.execute('''
CREATE TABLE IF NOT EXISTS entry_themes (
  entry_id TEXT NOT NULL REFERENCES entries(id) ON DELETE CASCADE,
  theme TEXT NOT NULL,
  confidence REAL NOT NULL
)
''');

  await db.execute('''
CREATE TABLE IF NOT EXISTS entry_reflections (
  entry_id TEXT PRIMARY KEY REFERENCES entries(id) ON DELETE CASCADE,
  reflection TEXT NOT NULL,
  provider TEXT NOT NULL,
  generated_at INTEGER NOT NULL
)
''');

  await db.execute('''
CREATE TABLE IF NOT EXISTS settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
)
''');

  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_entries_created_at ON entries(created_at DESC)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_entry_moods_entry ON entry_moods(entry_id)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_entry_themes_entry ON entry_themes(entry_id)',
  );

  // FTS5 is optional — not compiled into Android system SQLite on all devices.
  // Core entry saving works without it. Search will be enabled once the stack
  // moves to the sqlcipher native layer (which ships FTS5).
  try {
    await db.execute('''
CREATE VIRTUAL TABLE IF NOT EXISTS entries_fts USING fts5(
  entry_id UNINDEXED,
  body,
  prompt,
  transcript,
  tokenize='unicode61 remove_diacritics 1'
)
''');

    await db.execute('''
CREATE TRIGGER IF NOT EXISTS fts_entries_ai AFTER INSERT ON entries BEGIN
  INSERT INTO entries_fts(entry_id, body, prompt, transcript)
  VALUES (new.id, new.body, COALESCE(new.prompt, ''), '');
END
''');

    await db.execute('''
CREATE TRIGGER IF NOT EXISTS fts_entries_ad AFTER DELETE ON entries BEGIN
  DELETE FROM entries_fts WHERE entry_id = old.id;
END
''');

    await db.execute('''
CREATE TRIGGER IF NOT EXISTS fts_entries_au AFTER UPDATE OF body, prompt ON entries BEGIN
  DELETE FROM entries_fts WHERE entry_id = old.id;
  INSERT INTO entries_fts(entry_id, body, prompt, transcript)
  SELECT new.id, new.body, COALESCE(new.prompt, ''),
         COALESCE((SELECT transcript FROM voice_transcripts WHERE entry_id = new.id), '');
END
''');

    await db.execute('''
CREATE TRIGGER IF NOT EXISTS fts_transcripts_ai AFTER INSERT ON voice_transcripts BEGIN
  DELETE FROM entries_fts WHERE entry_id = new.entry_id;
  INSERT INTO entries_fts(entry_id, body, prompt, transcript)
  SELECT e.id, e.body, COALESCE(e.prompt, ''), new.transcript
  FROM entries e WHERE e.id = new.entry_id;
END
''');

    await db.execute('''
CREATE TRIGGER IF NOT EXISTS fts_transcripts_ad AFTER DELETE ON voice_transcripts BEGIN
  DELETE FROM entries_fts WHERE entry_id = old.entry_id;
  INSERT INTO entries_fts(entry_id, body, prompt, transcript)
  SELECT e.id, e.body, COALESCE(e.prompt, ''), ''
  FROM entries e WHERE e.id = old.entry_id;
END
''');

    await db.execute('''
CREATE TRIGGER IF NOT EXISTS fts_transcripts_au AFTER UPDATE OF transcript ON voice_transcripts BEGIN
  DELETE FROM entries_fts WHERE entry_id = old.entry_id;
  INSERT INTO entries_fts(entry_id, body, prompt, transcript)
  SELECT e.id, e.body, COALESCE(e.prompt, ''), new.transcript
  FROM entries e WHERE e.id = new.entry_id;
END
''');
  } catch (e) {
    debugPrint('FTS5 unavailable — full-text search index skipped: $e');
  }
}
