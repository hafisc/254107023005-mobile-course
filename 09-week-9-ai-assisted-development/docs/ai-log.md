# AI Log & Verification - Week 9: AI-Assisted Development / Vibe Coding

**Project**: `09-week-9-ai-assisted-development` (Offline Notes Search & Filter)  
**Tanggal**: 2 November 2026  
**Developer**: Hafis (254107023005)  
**AI Assistant**: Claude / Gemini Advanced Coding Assistant  

---

## 1. Praktikum 1: Prompt & Context Engineering

### Formula 5 Slot
Satu prompt yang efektif harus mengisi lima slot secara ringkas dan terukur:

| Slot | Konten |
|---|---|
| **1. Peran** | Senior Flutter & Clean Architecture Developer |
| **2. Konteks** | Offline Notes App (Flutter SDK, Riverpod 3, SQLite `sqflite`, Feature-first / Clean Architecture) |
| **3. Tugas** | Tambahkan fitur pencarian (search) catatan berdasarkan judul/isi + visual Empty State saat tidak ada catatan atau pencarian tidak cocok |
| **4. Batas** | Jangan langgar aturan dependensi (Domain layer steril tanpa import Flutter/Dio/SQLite), fungsi/widget maksimal 80 baris, tanpa hardcoded token |
| **5. Output** | Kode `filterNotes` murni di domain, Notifier/Provider di presentation, Widget UI `EmptyStateWidget`, unit test & widget test, serta cara uji |

### Prompt Inti yang Digunakan (Raw Prompt)
```text
Peran: Senior Flutter Developer
Konteks: Project offline notes dengan Riverpod 3 dan arsitektur bersih (presentation -> domain <- data). 
File Note entity: lib/data/local/note.dart dengan properti: id, title, body, updatedAt, dirty.
Tugas: Buat fitur pencarian catatan (search) berdasarkan kata kunci pada title dan body, serta EmptyStateWidget interaktif ketika query tidak menghasilkan data atau daftar masih kosong.
Batas: 
- Logika filter harus berupa fungsi/use case murni di domain layer (tanpa import Flutter, Dio, atau SQLite).
- State query dan filtered list dikelola via Riverpod Provider / Notifier.
- Fungsi maksimal 40 baris, widget maksimal 80 baris.
- Buat unit test mandiri untuk filterNotes (sukses, gagal/kosong, case-insensitive, whitespace trim) dan widget test untuk EmptyStateWidget.
Output: Kode Dart untuk UseCase domain, Widget, Notifier Provider, unit test, dan widget test.
```

---

## 2. Praktikum 2: Output Awal AI & Verifikasi 6 Langkah

### Output Awal AI (Sebelum Refactor)
Pada percobaan pertama, AI mengusulkan kode berikut:
```dart
// Usulan awal AI untuk filter di dalam widget:
class _NotesPageState extends State<NotesPage> {
  String query = '';

  List<Note> get filteredNotes {
    return widget.allNotes.where((note) {
      return note.title.contains(query); // <-- BUG & PELANGGARAN ARSITEKTUR
    }).toList();
  }
  ...
}
```

### Verifikasi 6 Langkah:
1. **Baca Tiap Baris**: Kode awal AI menaruh getter filter langsung di dalam widget `_NotesPageState` dan menggunakan `contains(query)` langsung tanpa lowercase.
2. **Cek Import**: AI sempat mengusulkan import `package:flutter/material.dart` di dalam file filter domain untuk memakai `TextEditingValue`. (Ditolak, harus string murni).
3. **Cek API**: AI sempat menggunakan syntax Riverpod lama `StateProvider<String>` yang sudah usang di Riverpod 3. Diperbaiki menjadi `NotifierProvider<SearchQueryNotifier, String>`.
4. **Jalankan Static Analysis**: `flutter analyze` berhasil 0 issues setelah syntax disesuaikan ke standar terkini.
5. **Test Bukti (Test Merah -> Test Hijau)**: Dibuat test kasus `filterNotes(notes, 'belanja')` yang awalnya gagal (merah) karena case-sensitive, lalu diperbaiki hingga hijau.
6. **Uji Manual**: Dicoba pada 3 variasi query:
   - Query kosong `""` ➡️ Menampilkan seluruh 4 catatan.
   - Query cocok `"belanja"` ➡️ Menampilkan 2 catatan (Belanja Bulanan & Belanja Elektronik).
   - Query tak cocok `"zzz-tak-ada"` ➡️ Menampilkan `EmptyStateWidget` dengan tombol "Hapus Pencarian".

---

## 3. Praktikum 3: Halusinasi AI & Debugging dengan Test Merah

### Halusinasi & Bug Nyata yang Ditemukan

#### 1. Bug Case-Sensitive Filter (Halusinasi Logika AI)
- **Akar Masalah**: AI menulis `note.title.contains(query)`. Jika catatan berjudul `"Daftar Belanja"` dan pengguna mencari `"belanja"`, filter mengembalikan `false`!
- **Langkah Reproduksi**:
  1. Catatan memiliki judul `"Daftar Belanja Bulanan"`.
  2. Masukkan query `"belanja"` (huruf kecil).
  3. Catatan tidak muncul padahal seharusnya cocok.
- **Test Merah Pembukti (Failing Test)**:
  ```dart
  test('filter abaikan huruf besar/kecil (FAILING SAMPLE)', () {
    final result = notes.where((n) => n.title.contains('belanja')).toList();
    expect(result, hasLength(2)); // GAGAL: Actual length 0
  });
  ```
- **Perbaikan Kode**:
  ```dart
  final trimmed = query.trim().toLowerCase();
  if (trimmed.isEmpty) return notes;
  return notes.where((n) => 
    n.title.toLowerCase().contains(trimmed) || 
    n.body.toLowerCase().contains(trimmed)
  ).toList();
  ```

#### 2. Pelanggaran Batas Layer (Arsitektur Leak)
- **Akar Masalah**: AI meletakkan logika komputasi filter di dalam method `build()` widget UI, bukan di Domain Use Case murni. Akibatnya logika filter tidak bisa di-unit test secara independen tanpa mem-pump widget Flutter.
- **Perbaikan**: Memisahkan fungsi murni `filterNotes()` dan class `SearchNotesUseCase` ke `lib/domain/usecases/filter_notes_usecase.dart` yang steril dari framework Flutter.

---

## 4. AI Challenge: Review Kode oleh Senior Dev AI

### Review AI (Prompt Challenge)
Prompt review senior dev dijalankan pada implementasi pencarian:
> *"Review kode search Flutter ini sebagai senior dev. Konteks: feature-first (presentation -> domain <- data), Riverpod, SQLite + Dio. Fokus: kebenaran, arsitektur, test. Abaikan style. Beri 3 temuan + level blocker/saran + alasan."*

### Tabel Temuan AI vs Keputusan Developer

| # | Temuan AI | Level | Kategori | Keputusan | Alasan & Tindak Lanjut |
|---|---|---|---|---|---|
| **1** | Spasi di awal/akhir query (`"  belanja  "`) tidak di-trim sehingga query bisa gagal mencocokkan kata | Major | Kebenaran | **DITERIMA & DIPERBAIKI** | Sangat valid. Ditambahkan `.trim()` sebelum evaluasi `.toLowerCase()`. Ditambahkan unit test pembukti. |
| **2** | Filter hanya memeriksa `title`, mengabaikan isi catatan (`body`) | Saran | Fungsionalitas | **DITERIMA & DIPERBAIKI** | Pengguna sering mengingat isi catatan daripada judulnya. Ditambahkan pengecekan `titleMatch \|\| bodyMatch`. |
| **3** | Usulan AI: Pindahkan pencarian ke query database SQLite (`SELECT * WHERE title LIKE ?`) setiap kali user mengetik karakter | Blocker (Anti-pattern) | Arsitektur & Performa | **DITOLAK** | **Alasan Teknis**: Untuk aplikasi offline notes skala personal (puluhan hingga ratusan catatan), in-memory filtering via Riverpod UseCase berjalan instan (0 ms), tidak membebani Disk I/O SQLite, tidak memerlukan async debouncing kompleks, dan menjaga pure offline-first architecture. Saran AI over-engineering untuk use-case ini. |

---

## 5. Ringkasan Verifikasi Mesin

| Pemeriksaan | Perintah | Hasil | Status |
|---|---|---|---|
| Static Analysis | `flutter analyze` | `No issues found! (ran in 2.0s)` | ✅ BERSIH |
| Code Formatter | `dart format lib test` | `Formatted 18 files in 0.54s` | ✅ RAPI |
| Unit & Widget Tests | `flutter test` | `12/12 tests passed!` | ✅ SEMUA HIJAU |
