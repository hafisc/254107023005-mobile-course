# Temuan Profiling - Week 11

**Aplikasi**: Catatan Offline + Asisten AI (lanjutan Week 10), diisi **2.000 catatan**
**Perangkat**: Emulator Pixel 7 (Android, x86_64), `flutter drive --profile`
**Skenario** (`integration_test/perf_test.dart`): scroll cepat 12x, mengetik `belanja 1` huruf per huruf, buka detail lalu kembali 5x

Setiap temuan di bawah diambil dari **data profiling**, bukan dari menebak isi kode.

---

## Temuan 1 - Seluruh halaman rebuild di setiap ketikan search

- **Bukti**: `test/rebuild_count_test.dart` menghitung rebuild per widget dengan `debugOnRebuildDirtyWidget`. Saat mengetik `belanja 1` (9 huruf): `NotesPage` 9x, `AppBar` 9x, `Badge` 9x, `TextField` 9x, `NoteTile` 88x.
- **Penyebab**: `NotesPage` melakukan `ref.watch(searchQueryProvider)`, `ref.watch(filteredNotesProvider)`, dan `ref.watch(dirtyCountProvider)` di level halaman. Perubahan query membuat AppBar dan badge, yang tidak berhubungan dengan search, ikut di-build ulang.

## Temuan 2 - Filter membuat ribuan string baru di setiap ketikan

- **Bukti**: skenario search memicu garbage collection hingga 176 ms total (`total_ui_gc_time`). Micro-benchmark di perangkat: `filterNotes` pada 2.000 catatan = **0,93 ms per ketikan**.
- **Penyebab**: `filterNotes` memanggil `title.toLowerCase()` dan `body.toLowerCase()` untuk setiap catatan di setiap ketikan, yaitu sekitar 4.000 string baru per huruf.

## Temuan 3 - Halaman detail memuat seluruh tabel untuk 1 catatan

- **Bukti**: timeline skenario detail berisi **2.060 event `Dart_StringToUTF8`** (konversi string dari SQLite), padahal yang ditampilkan hanya 1 catatan. Micro-benchmark: membuka detail = **34-54 ms**.
- **Penyebab**: `noteDetailProvider` memanggil `fetchNotes()` (2.000 baris) lalu `firstWhere`.

## Temuan 4 - Cache posts tidak pernah memperbarui UI dan selalu memanggil jaringan

- **Bukti (kode + jaringan)**: `loadPostsCacheFirst()` memanggil `refreshPostsInBackground()` tanpa memberi tahu provider, sehingga data segar baru terlihat setelah halaman dibuka ulang. Setiap kali halaman dibuka, request baru dikirim dengan `Dio` baru. Response yang diunduh **27.520 byte (100 post)**, lalu 90 di antaranya dibuang (`take(10)`).

## Temuan 5 - `GoRouter` tidak pernah di-dispose (memory leak)

- **Bukti**: `test/leak/memory_leak_test.dart` (leak tracker Flutter) melaporkan `notDisposed: GoRouterDelegate, GoRouteInformationProvider`.
- **Penyebab**: `appRouterProvider` membuat `GoRouter` tanpa `ref.onDispose(router.dispose)`.

## Bukan masalah (dicek, lalu tidak diubah)

| Dugaan | Hasil pengecekan |
|---|---|
| "`openNotesDb()` dipanggil di setiap operasi = DB dibuka berulang" | `sqflite` default `singleInstance: true` (dicek di source `sqflite_common`), sehingga path yang sama mengembalikan koneksi yang sudah terbuka. **Tidak diubah.** |
| "List perlu diganti `ListView.builder`" | Semua list sudah memakai `ListView.builder`. Skenario scroll paling ringan (build rata-rata 4,5 ms). **Tidak diubah.** |
| "Raster jank tinggi (~240 dari 250 frame saat scroll)" | Terjadi juga pada kode yang tidak diubah. Penyebabnya GPU emulator (Impeller di atas OpenGLES emulasi), bukan kode Dart. **Tidak dijadikan target.** |
| "Pagination untuk 2.000 catatan" | `ListView.builder` hanya membangun item yang terlihat; memuat 2.000 baris tidak muncul sebagai bottleneck di profiling. **Ditunda** sampai ada bukti. |
