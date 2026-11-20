// Widget test fitur utama: daftar catatan + form tambah catatan.
// App dijalankan lengkap (router asli), hanya sumber data diganti fake.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:week12_testing_quality_assurance/data/local/note.dart';
import 'package:week12_testing_quality_assurance/data/providers.dart';
import 'package:week12_testing_quality_assurance/main.dart';
import 'package:week12_testing_quality_assurance/pages/add_note_page.dart';

import 'fakes/fake_note_repository.dart';

const _addButton = Key('add-note-button');

Future<void> _pumpApp(WidgetTester tester, FakeNoteRepository repo) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(
    ProviderScope(
      overrides: [noteRepositoryProvider.overrideWithValue(repo)],
      // Tanpa retry otomatis Riverpod 3, keadaan error langsung terlihat.
      retry: (_, _) => null,
      child: const MyApp(),
    ),
  );
}

Future<void> _openForm(WidgetTester tester) async {
  await tester.tap(find.byKey(_addButton));
  await tester.pumpAndSettle();
  expect(find.text('Tambah Catatan'), findsOneWidget);
}

Future<void> _fillAndSave(
  WidgetTester tester, {
  required String title,
  String body = '',
}) async {
  await tester.enterText(find.byKey(AddNotePage.titleFieldKey), title);
  await tester.enterText(find.byKey(AddNotePage.bodyFieldKey), body);
  await tester.tap(find.byKey(AddNotePage.saveButtonKey));
}

Note _note(int id, String title) =>
    Note(id: id, title: title, updatedAt: DateTime(2026, 11, 1));

void main() {
  group('Daftar catatan', () {
    testWidgets('tampilan awal menampilkan catatan dari repository', (
      tester,
    ) async {
      await _pumpApp(tester, FakeNoteRepository(notes: [_note(1, 'Belanja')]));
      await tester.pumpAndSettle();

      expect(find.text('Catatan Offline'), findsOneWidget);
      expect(find.text('Belanja'), findsOneWidget);
      expect(find.byKey(_addButton), findsOneWidget);
    });

    testWidgets('indikator loading tampil selama data dimuat', (tester) async {
      final gate = Completer<void>();
      await _pumpApp(tester, FakeNoteRepository(fetchGate: gate));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      gate.complete();
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.textContaining('Belum ada catatan'), findsOneWidget);
    });

    testWidgets('data kosong menampilkan empty state', (tester) async {
      await _pumpApp(tester, FakeNoteRepository());
      await tester.pumpAndSettle();

      expect(find.textContaining('Belum ada catatan'), findsOneWidget);
    });

    testWidgets('error memuat menampilkan pesan, bukan daftar kosong', (
      tester,
    ) async {
      await _pumpApp(
        tester,
        FakeNoteRepository(fetchError: Exception('db terkunci')),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('db terkunci'), findsOneWidget);
      expect(find.textContaining('Belum ada catatan'), findsNothing);
    });
  });

  group('Form tambah catatan', () {
    testWidgets('judul kosong: pesan validasi, tidak menyimpan', (
      tester,
    ) async {
      final repo = FakeNoteRepository();
      await _pumpApp(tester, repo);
      await tester.pumpAndSettle();
      await _openForm(tester);

      await _fillAndSave(tester, title: '   ', body: 'isi tanpa judul');
      await tester.pumpAndSettle();

      expect(find.text('Judul wajib diisi'), findsOneWidget);
      expect(repo.added, isEmpty);
      expect(find.text('Tambah Catatan'), findsOneWidget, reason: 'tetap');
    });

    testWidgets('judul terlalu panjang: pesan validasi, tidak menyimpan', (
      tester,
    ) async {
      final repo = FakeNoteRepository();
      await _pumpApp(tester, repo);
      await tester.pumpAndSettle();
      await _openForm(tester);

      await _fillAndSave(tester, title: 'x' * 81);
      await tester.pumpAndSettle();

      expect(find.text('Judul maksimal 80 karakter'), findsOneWidget);
      expect(repo.added, isEmpty);
    });

    testWidgets('sukses: kembali ke daftar dan catatan baru tampil', (
      tester,
    ) async {
      final repo = FakeNoteRepository(notes: [_note(1, 'Catatan lama')]);
      await _pumpApp(tester, repo);
      await tester.pumpAndSettle();
      await _openForm(tester);

      await _fillAndSave(tester, title: '  Rapat PBL  ', body: ' jam 10 ');
      await tester.pumpAndSettle();

      expect(find.text('Tambah Catatan'), findsNothing);
      expect(find.text('Rapat PBL'), findsOneWidget);
      expect(find.text('Catatan lama'), findsOneWidget);
      // Spasi di awal/akhir dibuang sebelum disimpan.
      expect(repo.added.single, (title: 'Rapat PBL', body: 'jam 10'));
    });

    testWidgets('tombol nonaktif selama menyimpan (tidak tersimpan dobel)', (
      tester,
    ) async {
      final gate = Completer<void>();
      final repo = FakeNoteRepository(addGate: gate);
      await _pumpApp(tester, repo);
      await tester.pumpAndSettle();
      await _openForm(tester);

      await _fillAndSave(tester, title: 'Sekali saja');
      await tester.pump();
      expect(find.text('Menyimpan…'), findsOneWidget);
      await tester.tap(find.byKey(AddNotePage.saveButtonKey));
      await tester.pump();

      gate.complete();
      await tester.pumpAndSettle();
      expect(repo.added, hasLength(1));
      expect(find.text('Sekali saja'), findsOneWidget);
    });

    testWidgets(
      'gagal simpan: snackbar error, input tetap ada untuk dicoba lagi',
      (tester) async {
        final repo = FakeNoteRepository(addError: Exception('disk penuh'));
        await _pumpApp(tester, repo);
        await tester.pumpAndSettle();
        await _openForm(tester);

        await _fillAndSave(tester, title: 'Penting');
        await tester.pumpAndSettle();

        expect(
          find.text('Gagal menyimpan catatan. Coba lagi.'),
          findsOneWidget,
        );
        expect(find.text('Tambah Catatan'), findsOneWidget);
        expect(
          find.text('Penting'),
          findsOneWidget,
          reason: 'input tidak hilang',
        );
        expect(
          find.text('Simpan'),
          findsOneWidget,
          reason: 'tombol aktif lagi',
        );

        // Coba lagi setelah masalah hilang: berhasil.
        repo.addError = null;
        await tester.tap(find.byKey(AddNotePage.saveButtonKey));
        await tester.pumpAndSettle();
        expect(find.text('Tambah Catatan'), findsNothing);
        expect(find.text('Penting'), findsOneWidget);
      },
    );
  });
}
