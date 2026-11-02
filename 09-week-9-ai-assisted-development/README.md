# Offline Notes - Week 9: AI-Assisted Development & Vibe Coding

Aplikasi Catatan Offline (Offline-First) dengan local database SQLite (`sqflite`), state management Riverpod 3, dan arsitektur bersih (*Clean Architecture*). 

Pada **Minggu 9**, aplikasi ditingkatkan dengan menambahkan **fitur pencarian (search) judul & isi catatan** serta **Empty State interaktif** menggunakan alur kerja *AI-Assisted Development* yang teruji secara disiplin.

---

## 🚀 Fitur Baru (Week 9)
- **Real-time Search Filter**: Pencarian catatan secara instan berdasarkan kata kunci judul maupun isi catatan (*case-insensitive* dan *auto-trimmed*).
- **Interactive Empty State**: Tampilan visual informatif saat catatan belum ada atau hasil pencarian tidak ditemukan, dilengkapi tombol aksi *"Hapus Pencarian"*.
- **Clean Architecture Use Case**: Logika filter diekstrak ke `SearchNotesUseCase` di lapisan Domain murni (100% terisolasi dari framework Flutter dan database).
- **Riverpod 3 Notifier**: Pengelolaan query dan hasil filter reaktif menggunakan `NotifierProvider` terkini.

---

## 🎯 Formula Prompt 5 Slot

Penerapan prompt terstruktur sesuai panduan Codelab Minggu 9:

| Slot | Penerapan pada Fitur Search |
|---|---|
| **1. Peran** | Senior Flutter & Clean Architecture Developer |
| **2. Konteks** | Offline Notes App (Riverpod 3, SQLite `sqflite`, Feature-first / Clean Architecture) |
| **3. Tugas** | Tambahkan fitur pencarian catatan (search) berdasarkan judul & isi + `EmptyStateWidget` |
| **4. Batas** | Logika filter murni di Domain layer (tanpa import Flutter/Dio/SQLite), fungsi maks 40 baris, widget maks 80 baris |
| **5. Output** | UseCase Domain, Widget Presentation, Notifier Provider, unit tests, dan widget tests |

*(Log lengkap prompt mentah dan output awal AI tersimpan di [`docs/ai-log.md`](docs/ai-log.md))*

---

## 🏗️ Struktur Arsitektur

```
lib/
├── data/
│   ├── local/
│   │   ├── db.dart              # SQLite database helper
│   │   └── note.dart            # Note data model
│   ├── repositories/
│   │   └── note_repository.dart # Local repository
│   ├── providers.dart           # Riverpod providers (searchQuery, filteredNotes, notes)
│   └── sync.dart                # Mock sync engine
├── domain/
│   └── usecases/
│       └── filter_notes_usecase.dart  # Pure Dart search use case (Zero Flutter imports!)
├── pages/
│   ├── notes_page.dart          # UI Notes List + Search TextField
│   ├── note_detail_page.dart    # Detail view
│   ├── posts_page.dart          # Cached posts demo
│   └── settings_page.dart       # Preferences
└── widgets/
    ├── empty_state.dart         # EmptyStateWidget
    └── note_tile.dart           # Note list item tile
```

---

## 🧪 Bukti Mesin Hijau (Quality Checks)

### 1. Static Analysis (`flutter analyze`)
```bash
flutter analyze
```
> **Hasil**:
> ```text
> Analyzing 09-week-9-ai-assisted-development...
> No issues found! (ran in 2.0s)
> ```
> ✅ **0 Error, 0 Warning, 0 Info**

### 2. Code Formatter (`dart format`)
```bash
dart format lib test
```
> **Hasil**:
> ```text
> Formatted 18 files in 0.54 seconds.
> ```
> ✅ **Semua berkas terformat rapi sesuai panduan linter resmi Dart.**

### 3. Automated Tests (`flutter test`)
```bash
flutter test --reporter=expanded
```
> **Hasil**:
> ```text
> 00:00 +0: EmptyStateWidget Tests menampilkan pesan dan icon dengan benar
> 00:00 +1: fromMap aman terhadap field yang hilang
> 00:00 +2: EmptyStateWidget Tests menampilkan tombol aksi dan memicu callback ketika ditekan
> 00:01 +3: flag dirty bertahan pada serialisasi
> 00:01 +4: provider sukses dengan repository palsu
> 00:01 +5: provider error dengan repository palsu
> 00:01 +6: Search & Filter Notes UseCase Unit Tests filter abaikan huruf besar/kecil
> 00:01 +7: Search & Filter Notes UseCase Unit Tests query tak cocok kembalikan kosong
> 00:01 +8: Search & Filter Notes UseCase Unit Tests query kosong kembalikan seluruh catatan
> 00:01 +9: Search & Filter Notes UseCase Unit Tests query dengan spasi di awal dan akhir di-trim dengan benar
> 00:01 +10: Search & Filter Notes UseCase Unit Tests filter dapat mencocokkan teks yang berada di dalam body catatan
> 00:01 +11: Search & Filter Notes UseCase Unit Tests SearchNotesUseCase class mengeksekusi logika yang identik
> 00:01 +12: All tests passed!
> ```
> ✅ **12/12 Tests Lulus (Unit Tests & Widget Tests)**

---

## 🤖 AI Challenge: Evaluasi Kritis Terhadap Saran AI

| Temuan Saran AI | Kategori | Keputusan | Alasan Teknis |
|---|---|---|---|
| Auto-trim whitespace query (`" belanja "`) | Kebenaran | **DITERIMA** | Mencegah kesalahan input pengguna |
| Pencarian mencakup isi catatan (`body`) | Fitur | **DITERIMA** | Meningkatkan relevansi pencarian catatan |
| Pindahkan filter ke SQLite Query (`LIKE %query%`) | Performa / Arsitektur | **DITOLAK** | Menimbulkan overhead Disk I/O dan latensi asinkron yang tidak perlu untuk catatan offline skala personal |

Detail analisis dan pembuktian test merah tercatat di [`docs/ai-log.md`](docs/ai-log.md).  
Refleksi komprehensif atas 4 pertanyaan Codelab tercatat di [`docs/refleksi.md`](docs/refleksi.md).

---

## 🏃 Cara Menjalankan

1. **Masuk ke direktori project:**
   ```bash
   cd 09-week-9-ai-assisted-development
   ```
2. **Unduh dependensi:**
   ```bash
   flutter pub get
   ```
3. **Jalankan pengujian:**
   ```bash
   flutter test
   flutter analyze
   ```
4. **Jalankan aplikasi (Emulator / Device):**
   ```bash
   flutter run
   ```

---

## 👤 Informasi Mahasiswa

- **Nama**: Hafis
- **NIM**: 254107023005
- **Mata Kuliah**: Pemrograman Mobile (Semester 5)
- **Jurusan**: Teknologi Informasi - Politeknik Negeri Malang
