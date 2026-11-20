import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/ai_repository.dart';

/// API key disimpan terenkripsi (Keystore/Keychain), tidak pernah di kode.
class ApiKeyStore {
  ApiKeyStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'groq_api_key';
  final FlutterSecureStorage _storage;

  Future<String?> read() => _storage.read(key: _key);
  Future<void> save(String value) =>
      _storage.write(key: _key, value: value.trim());
  Future<void> delete() => _storage.delete(key: _key);
}

/// Kuota harian di SharedPreferences, reset otomatis saat tanggal berganti.
class PrefsQuotaStore implements AiQuotaStore {
  PrefsQuotaStore({DateTime Function()? now}) : _now = now ?? DateTime.now;

  static const _key = 'ai_quota';
  final DateTime Function() _now;

  String get _today => _now().toIso8601String().substring(0, 10);

  @override
  Future<int> usedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || !raw.startsWith('$_today|')) return 0;
    return int.tryParse(raw.split('|').last) ?? 0;
  }

  @override
  Future<void> increment() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, '$_today|${await usedToday() + 1}');
  }
}

/// Cache jawaban (maks [maxEntries], entri tertua dibuang lebih dulu).
class PrefsResponseCache implements AiResponseCache {
  PrefsResponseCache({this.maxEntries = 30});

  static const _key = 'ai_cache';
  final int maxEntries;

  Future<Map<String, String>> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return {};
    return Map<String, String>.from(jsonDecode(raw) as Map);
  }

  @override
  Future<String?> get(String question) async => (await _load())[question];

  @override
  Future<void> put(String question, String answer) async {
    final map = await _load()
      ..remove(question)
      ..[question] = answer;
    while (map.length > maxEntries) {
      map.remove(map.keys.first);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(map));
  }
}
