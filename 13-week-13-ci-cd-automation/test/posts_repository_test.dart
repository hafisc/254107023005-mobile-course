import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week13_ci_cd_automation/data/posts_repository.dart';
import 'package:week13_ci_cd_automation/data/providers.dart';

/// Adapter palsu: menghitung request yang benar-benar keluar ke jaringan.
class _CountingAdapter implements HttpClientAdapter {
  int calls = 0;
  bool offline = false;
  final List<Uri> uris = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    uris.add(options.uri);
    if (offline) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'offline',
      );
    }
    final items = [
      for (var i = 1; i <= 10; i++)
        {'id': i, 'title': 'segar $i', 'body': 'isi'},
    ];
    return ResponseBody.fromString(
      jsonEncode(items),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _MemoryStore implements PostsCacheStore {
  _MemoryStore([List<CachedPost>? initial]) : items = initial ?? [];
  List<CachedPost> items;

  @override
  Future<List<CachedPost>> read() async => items;

  @override
  Future<void> write(List<Map<String, dynamic>> raw) async =>
      items = raw.map(CachedPost.fromJson).toList();
}

void main() {
  late _CountingAdapter adapter;
  late DateTime clock;

  PostsRepository repo(_MemoryStore store) => PostsRepository(
    dio: Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = adapter,
    store: store,
    now: () => clock,
  );

  setUp(() {
    adapter = _CountingAdapter();
    clock = DateTime(2026, 11, 18, 10);
  });

  test('5x buka halaman dalam 5 menit -> hanya 1 request jaringan', () async {
    final r = repo(_MemoryStore());
    for (var i = 0; i < 5; i++) {
      await r.refresh();
      clock = clock.add(const Duration(seconds: 30));
    }
    expect(adapter.calls, 1);
  });

  test(
    'lewat 5 menit -> boleh request lagi; tombol refresh selalu jalan',
    () async {
      final r = repo(_MemoryStore());
      await r.refresh();
      clock = clock.add(const Duration(minutes: 6));
      await r.refresh();
      await r.refresh(force: true);
      expect(adapter.calls, 3);
    },
  );

  test('hanya meminta 10 item (_limit), bukan 100 lalu dibuang', () async {
    await repo(_MemoryStore()).refresh();
    expect(adapter.uris.single.queryParameters['_limit'], '10');
  });

  test('offline: refresh mengembalikan null dan cache lama utuh', () async {
    adapter.offline = true;
    final store = _MemoryStore([CachedPost(id: 1, title: 'lama', body: '')]);
    expect(await repo(store).refresh(), isNull);
    expect(store.items.single.title, 'lama');
  });

  test(
    'stale-while-revalidate: cache tampil dulu, lalu UI berganti data segar',
    () async {
      final store = _MemoryStore([CachedPost(id: 1, title: 'lama', body: '')]);
      final container = ProviderContainer(
        overrides: [postsRepositoryProvider.overrideWithValue(repo(store))],
      );
      addTearDown(container.dispose);
      final states = <String>[];
      container.listen(
        postsProvider,
        (_, next) => states.add(next.value?.first.title ?? 'loading'),
        fireImmediately: true,
      );

      final first = await container.read(postsProvider.future);
      expect(first.first.title, 'lama');
      // Revalidasi berjalan di background; tunggu (maks 1 detik).
      for (var i = 0; i < 100 && states.last != 'segar 1'; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }

      expect(container.read(postsProvider).value!.first.title, 'segar 1');
      expect(states, containsAllInOrder(['lama', 'segar 1']));
      expect(adapter.calls, 1);
    },
  );
}
