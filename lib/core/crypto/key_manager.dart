import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// Manages the database encryption key lifecycle.
///
/// NOTE: This currently uses SharedPreferences as a temporary store to keep
/// test/runtime compatibility stable. In production hardening, this should be
/// backed by flutter_secure_storage per security spec.
class KeyManager {
  static const _dbKeyPref = 'db.sqlcipher.key.base64';

  Future<String> getOrCreateDatabaseKey() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_dbKeyPref);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    final created = base64UrlEncode(bytes);
    await prefs.setString(_dbKeyPref, created);
    return created;
  }
}
