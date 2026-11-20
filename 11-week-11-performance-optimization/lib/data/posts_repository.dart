import 'dart:convert';

import 'package:dio/dio.dart';

import 'local/db.dart';

class CachedPost {
  CachedPost({required this.id, required this.title, required this.body});
  final int id;
  final String title;
  final String body;

  factory CachedPost.fromJson(Map<String, dynamic> json) {
    return CachedPost(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }
}

abstract interface class PostsCacheStore {
  Future<List<CachedPost>> read();
  Future<void> write(List<Map<String, dynamic>> items);
}

class SqlitePostsCacheStore implements PostsCacheStore {
  @override
  Future<List<CachedPost>> read() async {
    final db = await openNotesDb();
    final rows = await db.query('cached_posts', orderBy: 'id');
    return [
      for (final r in rows)
        CachedPost.fromJson(
          jsonDecode(r['payload'] as String) as Map<String, dynamic>,
        ),
    ];
  }

  @override
  Future<void> write(List<Map<String, dynamic>> items) async {
    final db = await openNotesDb();
    final now = DateTime.now().toIso8601String();
    await db.transaction((txn) async {
      await txn.delete('cached_posts');
      final batch = txn.batch();
      for (final item in items) {
        batch.insert('cached_posts', {
          'id': item['id'],
          'payload': jsonEncode(item),
          'cached_at': now,
        });
      }
      await batch.commit(noResult: true);
    });
  }
}

/// Minggu 11: satu instance Dio (koneksi bisa dipakai ulang) dan
/// pembatasan refresh. Versi lama membuat Dio baru dan memanggil jaringan
/// setiap kali halaman dibuka.
class PostsRepository {
  PostsRepository({
    Dio? dio,
    PostsCacheStore? store,
    DateTime Function()? now,
    this.minRefreshInterval = const Duration(minutes: 5),
    this.maxItems = 10,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: 'https://jsonplaceholder.typicode.com',
               connectTimeout: const Duration(seconds: 5),
               receiveTimeout: const Duration(seconds: 10),
             ),
           ),
       _store = store ?? SqlitePostsCacheStore(),
       _now = now ?? DateTime.now;

  final Dio _dio;
  final PostsCacheStore _store;
  final DateTime Function() _now;
  final Duration minRefreshInterval;
  final int maxItems;
  DateTime? _lastRefresh;

  Future<List<CachedPost>> readCache() => _store.read();

  /// Mengambil data segar dan menyimpannya ke cache.
  /// Mengembalikan `null` bila dilewati (belum [minRefreshInterval] sejak
  /// refresh terakhir) atau gagal (offline): cache lama tetap dipakai.
  Future<List<CachedPost>?> refresh({bool force = false}) async {
    final last = _lastRefresh;
    if (!force &&
        last != null &&
        _now().difference(last) < minRefreshInterval) {
      return null;
    }
    try {
      final response = await _dio.get<List<dynamic>>(
        '/posts',
        queryParameters: {'_limit': maxItems},
      );
      final items = (response.data ?? const [])
          .cast<Map<String, dynamic>>()
          .take(maxItems)
          .toList();
      await _store.write(items);
      _lastRefresh = _now();
      return items.map(CachedPost.fromJson).toList();
    } on DioException {
      return null;
    }
  }
}
