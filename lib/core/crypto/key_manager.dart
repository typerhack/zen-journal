import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the SQLCipher database encryption key lifecycle.
///
/// The 256-bit key is stored in the platform secure enclave:
///   iOS / macOS — Keychain
///   Android     — Android Keystore (hardware-backed on supported devices)
///   Windows     — Windows Credential Manager (DPAPI)
///   Linux       — Secret Service API (GNOME Keyring)
///
/// Migration: if a key exists in the legacy SharedPreferences location
/// (used during early development), it is moved to secure storage on first
/// access and removed from SharedPreferences. The database key itself does
/// not change — only where it is stored.
class KeyManager {
  static const _secureStorageKey = 'db.sqlcipher.key';
  static const _legacyPrefsKey = 'db.sqlcipher.key.base64';

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    mOptions: MacOsOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<String> getOrCreateDatabaseKey() async {
    // 1. Normal path — key already in secure storage.
    final stored = await _storage.read(key: _secureStorageKey);
    if (stored != null && stored.isNotEmpty) return stored;

    // 2. Migration path — key was written to SharedPreferences during early
    //    development. Move it to secure storage, then wipe from prefs.
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(_legacyPrefsKey);
    if (legacy != null && legacy.isNotEmpty) {
      await _storage.write(key: _secureStorageKey, value: legacy);
      await prefs.remove(_legacyPrefsKey);
      return legacy;
    }

    // 3. First launch — generate a new 256-bit key.
    final bytes = List<int>.generate(32, (_) => Random.secure().nextInt(256));
    final key = base64UrlEncode(bytes);
    await _storage.write(key: _secureStorageKey, value: key);
    return key;
  }
}
