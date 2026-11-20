// Langkah 5 codelab (memory profiling) versi otomatis: leak tracker Flutter
// gagal bila ada objek Disposable (controller, notifier, dll.) yang dibuat
// tetapi tidak di-dispose, atau di-dispose tetapi masih direferensikan.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:week12_testing_quality_assurance/data/ai/ai_providers.dart';
import 'package:week12_testing_quality_assurance/data/local/note.dart';
import 'package:week12_testing_quality_assurance/data/posts_repository.dart';
import 'package:week12_testing_quality_assurance/data/providers.dart';
import 'package:week12_testing_quality_assurance/main.dart';
import 'package:week12_testing_quality_assurance/pages/notes_page.dart';

class _Notes extends NotesNotifier {
  @override
  Future<List<Note>> build() async => [
    for (var i = 0; i < 50; i++)
      Note(id: i, title: 'Catatan nomor $i', updatedAt: DateTime(2026)),
  ];
}

class _NoPostsRepo extends PostsRepository {
  _NoPostsRepo() : super(store: _EmptyStore());
  @override
  Future<List<CachedPost>?> refresh({bool force = false}) async => null;
}

class _EmptyStore implements PostsCacheStore {
  @override
  Future<List<CachedPost>> read() async => [];
  @override
  Future<void> write(List<Map<String, dynamic>> items) async {}
}

List<Override> _overrides() => [
  notesProvider.overrideWith(_Notes.new),
  dirtyCountProvider.overrideWith((ref) async => 0),
  noteDetailProvider.overrideWith(
    (ref, id) async =>
        Note(id: id, title: 'Detail $id', updatedAt: DateTime(2026)),
  ),
  postsRepositoryProvider.overrideWithValue(_NoPostsRepo()),
  hasApiKeyProvider.overrideWith((ref) async => false),
  aiQuotaUsedProvider.overrideWith((ref) async => 0),
];

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
    'navigasi bolak-balik 5x tidak meninggalkan objek yang bocor',
    experimentalLeakTesting: LeakTesting.settings.withTrackedAll(),
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(overrides: _overrides(), child: const MyApp()),
      );
      await tester.pumpAndSettle();

      for (var i = 0; i < 5; i++) {
        await tester.tap(find.text('Catatan nomor $i'));
        await tester.pumpAndSettle();
        expect(find.text('Detail Catatan'), findsOneWidget);
        await tester.tap(find.byTooltip('Back'));
        await tester.pumpAndSettle();
      }
      for (final tooltip in ['Asisten AI', 'Pengaturan', 'Cached Posts']) {
        await tester.tap(find.byTooltip(tooltip));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Back'));
        await tester.pumpAndSettle();
      }
      expect(find.text('Catatan Offline'), findsOneWidget);
    },
  );

  testWidgets(
    'debounce search dibatalkan saat halaman dibuang (tidak ada error)',
    experimentalLeakTesting: LeakTesting.settings.withTrackedAll(),
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(),
          child: const MaterialApp(home: NotesPage()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'catatan');
      // Buang halaman sebelum debounce (250 ms) selesai.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    },
  );
}
