# Catatan Test - Week 12: Pengujian dan Jaminan Kualitas

Lanjutan aplikasi **Catatan Offline** (Week 11). Fitur utama yang diuji: **menambah catatan lewat form dengan validasi judul**. Sebelumnya tombol **+** selalu membuat "Catatan Baru" tanpa input. Pengujian mencakup unit, widget, dan integrasi, dan setiap test dibuktikan **bisa gagal** ketika fiturnya dirusak.

Refleksi: [`docs/refleksi.md`](docs/refleksi.md)

---

## 1. Skenario yang Diuji

| # | Skenario | Jenis | Kategori | File test |
|---|---|---|---|---|
| S1 | Judul berisi teks diterima; spasi di awal/akhir dibuang | Unit + widget | Sukses | `validate_note_title_test.dart`, `add_note_widget_test.dart` |
| S2 | Judul kosong / hanya spasi / tab / baris baru / `null` ditolak "Judul wajib diisi" | Unit + widget | Input tidak valid | idem |
| S3 | Batas 80 karakter: tepat 80 diterima, 81 ditolak | Unit + widget | **Kasus tepi** | idem |
| S4 | Emoji dihitung 1 karakter (bukan 2 unit UTF-16) | Unit | **Kasus tepi** | `validate_note_title_test.dart` |
| S5 | Simpan berhasil: kembali ke daftar, catatan baru tampil di atas | Unit + widget + **integrasi** | Sukses | `notes_notifier_test.dart`, `add_note_widget_test.dart`, `integration_test/app_test.dart` |
| S6 | Simpan gagal: snackbar error, input tidak hilang, bisa dicoba lagi | Unit + widget | **Kegagalan** | `notes_notifier_test.dart`, `add_note_widget_test.dart` |
| S7 | Tombol nonaktif selama menyimpan, tidak tersimpan dobel | Widget | Kasus tepi | `add_note_widget_test.dart` |
| S8 | Memuat gagal: tampil pesan error, **bukan** daftar kosong | Unit + widget | **Kegagalan** | `notes_notifier_test.dart`, `add_note_widget_test.dart` |
| S9 | Loading tampil selama data dimuat; data kosong tampil empty state | Widget | Keadaan UI | `add_note_widget_test.dart` |
| S10 | Hapus berhasil / gagal (catatan tetap ada bila gagal) | Unit + integrasi | Sukses / kegagalan | `notes_notifier_test.dart`, `integration_test/app_test.dart` |

### Pemisahan dependensi

- `NoteRepository` kini **interface**. Implementasi aslinya `SqliteNoteRepository`.
- Test unit dan widget memakai [`test/fakes/fake_note_repository.dart`](test/fakes/fake_note_repository.dart): data di memori, error per operasi (`fetchError`, `addError`, `deleteError`), `Completer` untuk menahan operasi (loading, simpan), dan catatan pemanggilan (`added`, `deletedIds`).
- Integration test memakai **SQLite asli** di emulator, tanpa fake.

---

## 2. Hasil Pemeriksaan

```bash
flutter analyze --fatal-infos
# No issues found!

dart format --output=none --set-exit-if-changed lib test integration_test
# Formatted 47 files (0 changed) in 0.94 seconds.

flutter test
# 00:16 +77: All tests passed!

flutter test integration_test/app_test.dart -d emulator-5554
# 00:07 +1: All tests passed!
```

Integration test dijalankan di emulator Pixel 7 (Android, x86_64) dan menguji alur: validasi judul kosong -> simpan -> catatan tampil dan **benar-benar ada di SQLite** -> dicari lewat search -> dihapus dengan swipe -> hilang dari UI **dan** database.

### Bukti test bisa gagal (uji mutasi manual)

Test yang selalu lulus tidak melindungi apa pun. Karena itu kode app sengaja dirusak satu per satu, `flutter test` dijalankan, lalu kodenya dikembalikan:

| Mutasi (kode dirusak) | Hasil | Test yang menangkap |
|---|---|---|
| M1 Validasi tidak membuang spasi | ✅ Tertangkap (3 test gagal) | judul kosong (widget), hanya spasi (unit), spasi di luar batas |
| M2 Panjang dihitung `.length` (UTF-16) | ✅ Tertangkap (1) | emoji dihitung 1 karakter |
| M3 Batas off-by-one (`>` jadi `>=`) | ✅ Tertangkap (3) | tepat 80 karakter diterima, dll. |
| M4 Judul disimpan tanpa `trim()` | ✅ Tertangkap (1) | sukses: kembali ke daftar |
| M5 Tombol tidak dikunci saat menyimpan | ✅ Tertangkap (1) | tidak tersimpan dobel |
| M6 Error simpan ditelan diam-diam | ✅ Tertangkap (2) | gagal simpan (unit + widget) |
| M7 Error memuat ditampilkan sebagai daftar kosong | ✅ Tertangkap (1) | error memuat menampilkan pesan |

### Cakupan (`flutter test --coverage`)

**Total 78,9%** (601/762 baris). Angka ini hanya petunjuk: yang dihitung adalah baris yang dijalankan, bukan perilaku yang diperiksa.

| File | Cakupan | Catatan |
|---|---|---|
| `domain/usecases/validate_note_title.dart` | 100% | |
| `pages/add_note_page.dart` | 100% | |
| `domain/usecases/filter_notes_usecase.dart`, `widgets/note_tile.dart`, `widgets/empty_state.dart` | 100% | |
| `data/providers.dart` | 77,8% | sinkronisasi (`syncData`) dan posts belum diuji di sini |
| `pages/notes_page.dart` | 77,3% | tombol sync dan navigasi ke halaman lain |
| `data/repositories/note_repository.dart` (`SqliteNoteRepository`) | **0%** | hanya teruji lewat integration test (tidak dihitung coverage) |

---

## 3. Temuan dari Pengujian

### Bug yang ditemukan dan diperbaiki

1. **`setState() called during build` saat kembali dari form** (ditemukan widget test "sukses: kembali ke daftar").
   Riverpod 3 menjeda provider milik halaman yang tertutup. Saat form ditutup, Flutter mengaktifkan lagi halaman daftar di tengah build. Riverpod lalu me-*resume* rantai `filteredNotesProvider -> searchIndexProvider -> notesProvider` dan memicu refresh provider di tengah build.
   Perbaikan butuh **dua bagian**, dan keduanya terbukti perlu (menghapus salah satunya membuat 3 test gagal lagi):
   - `NotesNotifier` memuat ulang data sebelum `addNote()` selesai (`invalidateSelf()` lalu `await future`);
   - filter dihitung di widget `NotesList`, sehingga rantai provider -> provider di bawah halaman itu hilang.
   Riverpod 3.4.0/3.4.1 mencatat perbaikan untuk error `markNeedsBuild` sejenis, tetapi butuh Dart >= 3.12 (project ini Dart 3.8.1).
2. **Test lama `provider error` memakai `Future.delayed(50 ms)`.** Diganti `expectLater(... throwsA(...))` tanpa jeda waktu tetap. Saat itu juga ditemukan bahwa **Riverpod 3 mengulang (retry) provider yang gagal secara otomatis**, sehingga `.future` tidak pernah selesai dengan error (test timeout 30 detik). Di test, retry dimatikan dengan `retry: (_, _) => null`.
3. **Fake lama meng-extend kelas SQLite asli**, sehingga method yang tidak di-override (`addNote`) akan memanggil database sungguhan lalu crash. Diganti interface + fake terpisah.
4. **Kesalahan di test integrasi sendiri:** `find.text(judul)` juga cocok dengan isi `TextField` search, sehingga pemeriksaan "catatan sudah terhapus" selalu gagal walaupun catatannya sudah hilang. Diganti `find.descendant(of: ListView, ...)`.

### Belum terselesaikan

- `SqliteNoteRepository` belum punya test unit di host. Butuh `sqflite_common_ffi` + `sqlite3.dll` di Windows. Saat ini hanya dilindungi integration test.
- Riverpod masih 3.3.2. Upgrade ke >= 3.4.1 (perbaikan resmi) butuh upgrade Flutter SDK.
- Penyimpanan emulator nyaris penuh: pemasangan pertama integration test gagal (`INSTALL_FAILED_INSUFFICIENT_STORAGE`), lalu Flutter meng-uninstall versi lama dan memasang ulang (data app di emulator ikut terhapus).
- Error memuat masih ditampilkan sebagai teks mentah `Error: Exception: ...`, belum pesan ramah pengguna.
- CI GitHub Actions belum bisa berjalan karena akun terkunci masalah billing.

---

## 🏃 Cara Menjalankan

```bash
cd 12-week-12-testing-quality-assurance
flutter pub get
flutter analyze
flutter test
flutter test --coverage            # hasil: coverage/lcov.info
flutter devices                    # cari <device_id>
flutter test integration_test/app_test.dart -d <device_id>
```

---

## 👤 Informasi Mahasiswa

- **Nama**: Hafis
- **NIM**: 254107023005
- **Mata Kuliah**: Pemrograman Mobile (Semester 5)
- **Jurusan**: Teknologi Informasi - Politeknik Negeri Malang
