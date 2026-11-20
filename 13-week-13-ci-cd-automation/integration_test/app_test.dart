// Integration test alur utama di perangkat/emulator dengan SQLite ASLI
// (tanpa fake): form -> simpan -> daftar -> cari -> hapus -> database.
//
//   flutter test integration_test/app_test.dart -d <device_id>
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:week13_ci_cd_automation/data/repositories/note_repository.dart';
import 'package:week13_ci_cd_automation/main.dart' as app;
import 'package:week13_ci_cd_automation/pages/add_note_page.dart';
import 'package:week13_ci_cd_automation/pages/notes_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('pengguna menambah, mencari, lalu menghapus catatan', (
    tester,
  ) async {
    // Judul unik agar tidak bentrok dengan data yang sudah ada di perangkat.
    final title = 'Uji integrasi ${DateTime.now().millisecondsSinceEpoch}';
    final repo = SqliteNoteRepository();
    // Cari judul HANYA di daftar: `find.text` juga mencocokkan isi TextField,
    // sehingga setelah judul diketik di kolom search, hasilnya selalu >= 1.
    final inList = find.descendant(
      of: find.byType(ListView),
      matching: find.text(title),
    );

    app.main();
    await tester.pumpAndSettle();
    expect(find.text('Catatan Offline'), findsOneWidget);

    // 1. Validasi tetap berjalan di perangkat sungguhan.
    await tester.tap(find.byKey(const Key('add-note-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(AddNotePage.saveButtonKey));
    await tester.pumpAndSettle();
    expect(find.text('Judul wajib diisi'), findsOneWidget);

    // 2. Simpan catatan.
    await tester.enterText(find.byKey(AddNotePage.titleFieldKey), title);
    await tester.enterText(
      find.byKey(AddNotePage.bodyFieldKey),
      'dibuat oleh integration test',
    );
    await tester.tap(find.byKey(AddNotePage.saveButtonKey));
    await tester.pumpAndSettle();
    expect(find.text('Tambah Catatan'), findsNothing);
    expect(inList, findsOneWidget);
    expect(
      (await repo.fetchNotes()).where((n) => n.title == title),
      hasLength(1),
      reason: 'benar-benar tersimpan di SQLite',
    );

    // 3. Cari (melewati debounce search).
    await tester.enterText(find.byType(TextField).first, title);
    await tester.pump(searchDebounce * 2);
    await tester.pumpAndSettle();
    expect(inList, findsOneWidget);

    // 4. Hapus dengan swipe, lalu pastikan hilang dari UI dan database.
    await tester.drag(inList, const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(inList, findsNothing);
    expect((await repo.fetchNotes()).where((n) => n.title == title), isEmpty);
  });
}
