# Refleksi - Week 9: AI-Assisted Development / Vibe Coding

**Nama**: Hafis  
**NIM**: 254107023005  
**Mata Kuliah**: Pemrograman Web / Mobile Course (Semester 5)  
**Tanggal**: 2 November 2026  

---

### 1. Satu halusinasi / bug AI apa yang Anda temukan dan bagaimana membuktikannya?
**Temuan**: Bug filter *case-sensitive* dan ketidakpedulian terhadap *whitespace*.
- **Halusinasi/Kelemahan AI**: Saat diminta membuat filter catatan, AI dengan percaya diri menulis `notes.where((note) => note.title.contains(query)).toList()`. Secara sekilas kode tampak benar dan bersih, tetapi terdapat cacat logika fatal: method `.contains()` di Dart bersifat case-sensitive. Jika catatan berjudul `"Daftar Belanja"` dan dicari dengan kata `"belanja"`, hasilnya kosong.
- **Cara Membuktikannya**: Saya membuat satu unit test merah (*failing test*) dengan input query huruf kecil pada data catatan berhuruf kapital:
  ```dart
  test('filter abaikan huruf besar/kecil', () {
    final result = filterNotes(sampleNotes, 'belanja');
    expect(result, hasLength(2));
  });
  ```
  Test tersebut awalnya gagal (*failed/red*). Setelah fungsi diperbaiki dengan `query.trim().toLowerCase()` dan `note.title.toLowerCase()`, barulah unit test berubah menjadi hijau (*passed/green*).

---

### 2. Prompt mana yang paling membantu dan apa yang Anda ubah?
**Prompt Paling Membantu**: Formula **5 Slot** (Peran, Konteks, Tugas, Batas, Output).
- **Sebelumnya (Prompt Vibe Coding Biasa)**: *"Buatkan fitur search untuk notes di Flutter beserta empty state."* ➡️ Hasilnya berantakan: AI menaruh logic filter langsung di dalam widget, mengimpor package sembarangan, dan memakai sintaks Riverpod lama.
- **Perubahan yang Dilakukan**:
  Saya memberikan batasan ketat (*slot Batas & Konteks*):
  - Menyebutkan versi library secara spesifik: *"Riverpod 3, SQLite `sqflite`"*.
  - Menegaskan aturan arsitektur: *"Logika filter wajib berupa pure Dart Use Case di Domain layer tanpa import Flutter/Dio/SQLite"*.
  - Membatasi ukuran kode: *"Maksimal 40 baris per fungsi, maksimal 80 baris per widget"*.
- **Dampak**: Output AI menjadi jauh lebih terstruktur, langsung memisahkan Domain Use Case dengan Presentation Notifier, serta menyertakan skenario test case yang relevan.

---

### 3. Satu refactor apa yang Anda lakukan pada kode AI?
**Refactor Utama**: Memindahkan Logika Filter dari State UI Widget ke **Domain Use Case Murni**.
- **Kode Asal AI**: AI menggabungkan controller input, filtering string, dan rendering list dalam satu file State widget (`_NotesPageState`).
- **Tindakan Refactor**:
  1. Membuat `lib/domain/usecases/filter_notes_usecase.dart` yang hanya berisi fungsi murni `filterNotes()` dan class `SearchNotesUseCase`. File ini sama sekali tidak mengimpor framework Flutter (`package:flutter`).
  2. Menyediakan `filteredNotesProvider` di `lib/data/providers.dart` yang mengamati `searchQueryProvider` dan `notesProvider`.
  3. Menyederhanakan `NotesPage` sehingga murni bertindak sebagai UI renderer (*Presentation Layer*).
- **Dampak**: Logika bisnis pencarian dapat di-unit test secara cepat (hanya 0.05 detik) tanpa memerlukan simulator perangkat atau `WidgetTester`.

---

### 4. Keputusan terima/tolak saran AI mana yang paling sulit?
**Keputusan**: **Menolak usulan AI untuk memindahkan pencarian ke SQLite Query (`WHERE title LIKE ?`).**
- **Alasan Dilema**: AI berargumen bahwa query database adalah *best practice* industri untuk database besar demi menghemat memori RAM. Argumen AI terdengar sangat meyakinkan.
- **Alasan Tetap Menolak**:
  1. **Konteks Aplikasi**: Aplikasi ini adalah catatan lokal offline-first berskala personal (rata-rata pengguna memiliki ratusan catatan, bukan jutaan).
  2. **Performa**: In-memory filtering di memori Dart untuk 1.000 catatan berjalan instan (< 1 milidetik) tanpa latensi I/O disk.
  3. **Kompleksitas Asinkron**: Jika dialihkan ke SQLite, setiap ketukan huruf pada search box membutuhkan mekanisme `Debounce` dan pembatalan query asinkron agar tidak terjadi *race condition* atau UI lag.
  4. **Konsistensi Arsitektur**: In-memory filter menjaga state tetap reaktif dan selaras dengan pola *Offline-First* Riverpod yang sudah dibangun dari Minggu 5.
- **Kesimpulan**: Developer harus memahami konteks dan trade-off aplikasinya sendiri. Tidak semua saran "optimasi" dari AI relevan atau dibutuhkan.

