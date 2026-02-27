import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/db/database.dart';
import '../domain/journal_entry.dart';

class EntryRepository {
  EntryRepository(this._database);

  final ZenDatabase _database;
  final Uuid _uuid = const Uuid();

  Future<List<JournalEntry>> listEntries() async {
    final db = await _database.open();
    final rows = await db.query('entries', orderBy: 'created_at DESC');
    return rows.map(JournalEntry.fromMap).toList();
  }

  Future<JournalEntry> createEntry({
    required String body,
    String? prompt,
  }) async {
    final now = DateTime.now();
    final trimmed = body.trim();
    final words = trimmed.isEmpty ? 0 : trimmed.split(RegExp(r'\s+')).length;

    final entry = JournalEntry(
      id: _uuid.v4(),
      createdAt: now,
      updatedAt: now,
      prompt: prompt,
      body: trimmed,
      wordCount: words,
    );

    final db = await _database.open();
    await db.insert('entries', entry.toMap());
    return entry;
  }

  Future<void> updateEntry({
    required String id,
    required String body,
    String? prompt,
  }) async {
    final trimmed = body.trim();
    final words = trimmed.isEmpty ? 0 : trimmed.split(RegExp(r'\s+')).length;
    final db = await _database.open();
    await db.update(
      'entries',
      <String, Object?>{
        'body': trimmed,
        'prompt': prompt,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'word_count': words,
      },
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }

  Future<void> deleteEntry(String id) async {
    final db = await _database.open();
    await db.delete('entries', where: 'id = ?', whereArgs: <Object?>[id]);
  }
}

final entryRepositoryProvider = Provider<EntryRepository>((ref) {
  return EntryRepository(ref.watch(zenDatabaseProvider));
});

class JournalEntriesController extends AsyncNotifier<List<JournalEntry>> {
  @override
  Future<List<JournalEntry>> build() async {
    try {
      return await ref.read(entryRepositoryProvider).listEntries();
    } on MissingPluginException {
      return const <JournalEntry>[];
    } catch (_) {
      return const <JournalEntry>[];
    }
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(entryRepositoryProvider).listEntries(),
    );
  }

  Future<void> createEntry({required String body, String? prompt}) async {
    await ref
        .read(entryRepositoryProvider)
        .createEntry(body: body, prompt: prompt);
    await reload();
  }

  Future<void> deleteEntry(String id) async {
    await ref.read(entryRepositoryProvider).deleteEntry(id);
    await reload();
  }
}

final journalEntriesProvider =
    AsyncNotifierProvider<JournalEntriesController, List<JournalEntry>>(
      JournalEntriesController.new,
    );
