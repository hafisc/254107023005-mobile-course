import 'dart:convert';
import 'package:dio/dio.dart';
import 'repositories/note_repository.dart';
import 'local/db.dart';
import 'dart:async';

Future<int> syncNotes(NoteRepository repo) async {
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;
  // Simulasi upload: pada project nyata, kirim tiap catatan dirty
  // ke REST API di sini, lalu tandai bersih bila server menjawab 2xx.
  await Future.delayed(const Duration(seconds: 1));
  await repo.markAllSynced();
  return dirtyCount;
}

// Untuk cache posts API dari Week 4
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

Future<List<CachedPost>> loadPostsCacheFirst() async {
  final db = await openNotesDb();
  final rows = await db.query('cached_posts');
  final cached = rows.map((r) {
    final payload = jsonDecode(r['payload'] as String);
    return CachedPost.fromJson(payload);
  }).toList();

  // 1. Segera kembalikan cache agar UI tidak blank saat offline.
  // 2. Di background: fetch Dio -> simpan ke cached_posts -> invalidate provider.
  unawaited(refreshPostsInBackground());

  return cached;
}

Future<void> refreshPostsInBackground() async {
  try {
    final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 3)));
    final response = await dio.get<List>('https://jsonplaceholder.typicode.com/posts');
    final data = response.data ?? [];
    
    final db = await openNotesDb();
    await db.transaction((txn) async {
      await txn.delete('cached_posts'); // hapus cache lama
      for (final item in data.take(10)) { // simpan 10 saja
        await txn.insert('cached_posts', {
          'id': item['id'],
          'payload': jsonEncode(item),
          'cached_at': DateTime.now().toIso8601String(),
        });
      }
    });
  } catch (_) {
    // Abaikan error jaringan saat di-background (offline mode)
  }
}
