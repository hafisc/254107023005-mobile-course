import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:flutter_test/flutter_test.dart';
import 'package:week13_ci_cd_automation/data/local/note.dart';
import 'package:week13_ci_cd_automation/data/providers.dart';

import 'fakes/fake_note_repository.dart';

/// Container uji. Dua perilaku Riverpod 3 perlu dikendalikan:
/// - `retry: null`: provider yang gagal TIDAK diulang otomatis. Tanpa ini
///   `.future` tidak pernah selesai dengan error (test timeout 30 detik).
/// - provider yang tidak di-listen dijeda; UI selalu me-listen, jadi test
///   juga me-listen lewat [_keepAlive].
ProviderContainer _container(FakeNoteRepository repo) {
  final container = ProviderContainer(
    overrides: [noteRepositoryProvider.overrideWithValue(repo)],
    retry: (_, _) => null,
  );
  addTearDown(container.dispose);
  return container;
}

void _keepAlive(ProviderContainer c, ProviderListenable<Object?> p) =>
    c.listen(p, (_, _) {});

Note _note(int id, String title) =>
    Note(id: id, title: title, updatedAt: DateTime(2026, 11, id));

void main() {
  group('NotesNotifier - memuat', () {
    test('meneruskan data dari repository', () async {
      // Arrange
      final repo = FakeNoteRepository(notes: [_note(1, 'Belanja')]);
      final container = _container(repo);
      // Act
      final notes = await container.read(notesProvider.future);
      // Assert
      expect(notes.map((n) => n.title), ['Belanja']);
    });

    test('error repository menjadi AsyncError, bukan daftar kosong', () async {
      final repo = FakeNoteRepository(fetchError: Exception('db terkunci'));
      final container = _container(repo);

      // Tanpa jeda waktu tetap: tunggu future provider sampai gagal.
      await expectLater(
        container.read(notesProvider.future),
        throwsA(isA<Exception>()),
      );
      final state = container.read(notesProvider);
      expect(state.hasError, isTrue);
      expect(state.hasValue, isFalse, reason: 'error tidak boleh jadi []');
      expect(state.error.toString(), contains('db terkunci'));
    });
  });

  group('NotesNotifier - menambah', () {
    test('catatan baru muncul di daftar setelah disimpan', () async {
      final repo = FakeNoteRepository(notes: [_note(1, 'Lama')]);
      final container = _container(repo);
      await container.read(notesProvider.future);

      await container.read(notesProvider.notifier).addNote('Baru', 'isi');

      final notes = await container.read(notesProvider.future);
      expect(notes.map((n) => n.title), ['Baru', 'Lama']);
      expect(repo.added.single, (title: 'Baru', body: 'isi'));
    });

    test(
      'gagal simpan: error diteruskan ke pemanggil, daftar tidak berubah',
      () async {
        final repo = FakeNoteRepository(
          notes: [_note(1, 'Lama')],
          addError: Exception('disk penuh'),
        );
        final container = _container(repo);
        await container.read(notesProvider.future);

        await expectLater(
          container.read(notesProvider.notifier).addNote('Baru', ''),
          throwsA(isA<Exception>()),
        );
        final notes = await container.read(notesProvider.future);
        expect(notes.map((n) => n.title), ['Lama']);
      },
    );
  });

  group('NotesNotifier - menghapus', () {
    test('catatan hilang dari daftar', () async {
      final repo = FakeNoteRepository(notes: [_note(1, 'A'), _note(2, 'B')]);
      final container = _container(repo);
      await container.read(notesProvider.future);

      await container.read(notesProvider.notifier).deleteNote(1);

      final notes = await container.read(notesProvider.future);
      expect(notes.map((n) => n.title), ['B']);
      expect(repo.deletedIds, [1]);
    });

    test('gagal hapus: error diteruskan, catatan tetap ada', () async {
      final repo = FakeNoteRepository(
        notes: [_note(1, 'A')],
        deleteError: Exception('gagal'),
      );
      final container = _container(repo);
      await container.read(notesProvider.future);

      await expectLater(
        container.read(notesProvider.notifier).deleteNote(1),
        throwsA(isA<Exception>()),
      );
      expect((await container.read(notesProvider.future)).single.title, 'A');
    });
  });

  test('jumlah belum sinkron mengikuti data repository', () async {
    final repo = FakeNoteRepository(
      notes: [
        Note(id: 1, title: 'a', updatedAt: DateTime(2026), dirty: true),
        Note(id: 2, title: 'b', updatedAt: DateTime(2026)),
      ],
    );
    final container = _container(repo);
    _keepAlive(container, dirtyCountProvider);
    expect(await container.read(dirtyCountProvider.future), 1);
  });
}
