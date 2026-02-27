import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../crypto/key_manager.dart';
import 'migrations/migration_1.dart';

const _databaseName = 'zen_journal.db';
const _databaseVersion = 1;

class ZenDatabase {
  ZenDatabase(this._keyManager);

  final KeyManager _keyManager;
  Database? _db;

  Future<Database> open() async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final fullPath = p.join(dbPath, _databaseName);
    final key = await _keyManager.getOrCreateDatabaseKey();
    final escapedKey = key.replaceAll("'", "''");

    try {
      _db = await _openDatabase(fullPath, escapedKey);
    } catch (e) {
      // A previous failed migration (e.g. FTS5 unavailable) can leave the DB
      // at user_version=0 with some tables already created. Every subsequent
      // open attempt then fails on "table already exists". Delete and recreate.
      debugPrint('Database open failed ($e) — deleting and recreating');
      await deleteDatabase(fullPath);
      _db = await _openDatabase(fullPath, escapedKey);
    }

    return _db!;
  }

  Future<Database> _openDatabase(String fullPath, String escapedKey) {
    return openDatabase(
      fullPath,
      version: _databaseVersion,
      onConfigure: (db) async {
        await db.execute("PRAGMA key = '$escapedKey'");
        await db.execute('PRAGMA foreign_keys = ON');
        try {
          await db.execute('PRAGMA journal_mode = WAL');
        } catch (error) {
          // Some SQLCipher builds/platforms reject WAL; continue with default mode.
          debugPrint('Skipping WAL journal mode: $error');
        }
      },
      onCreate: (db, version) async {
        await _applyMigrations(db, 0, version);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _applyMigrations(db, oldVersion, newVersion);
      },
    );
  }

  Future<void> close() async {
    if (_db == null) return;
    await _db!.close();
    _db = null;
  }

  Future<void> _applyMigrations(
    Database db,
    int fromVersion,
    int toVersion,
  ) async {
    for (var version = fromVersion + 1; version <= toVersion; version++) {
      switch (version) {
        case 1:
          await applyMigration1(db);
          break;
        default:
          throw StateError('Unknown migration version: $version');
      }
    }
  }
}

final keyManagerProvider = Provider<KeyManager>((ref) => KeyManager());

final zenDatabaseProvider = Provider<ZenDatabase>((ref) {
  final db = ZenDatabase(ref.watch(keyManagerProvider));
  ref.onDispose(() {
    unawaited(db.close());
  });
  return db;
});
