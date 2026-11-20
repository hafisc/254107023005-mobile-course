# Performance Report - Week 11: Optimasi Performa

**Tanggal**: 18 November 2026
**Basis**: aplikasi Catatan Offline + Asisten AI dari Week 10 (`10-week-10-ai-feature-integration/` = kode *sebelum*)
**Data uji**: 2.000 catatan (`integration_test/seed.dart`)
**Perangkat**: emulator Pixel 7, Android x86_64, mode **profile**

Detail temuan profiling: [`performance-findings.md`](performance-findings.md).

---

## 1. Cara mengukur

| Yang diukur | Alat | File |
|---|---|---|
| Frame time, jank, GC | `flutter drive --profile` + `traceAction` (timeline) | `integration_test/perf_test.dart`, `test_driver/perf_driver.dart` |
| Ongkos CPU / DB per operasi | micro-benchmark di perangkat, lama vs baru dalam 1 run, 3 putaran | `integration_test/bench_test.dart` |
| Jumlah rebuild per widget | `debugOnRebuildDirtyWidget` di widget test | `test/rebuild_count_test.dart` |
| Jumlah request jaringan | `HttpClientAdapter` palsu yang menghitung request | `test/posts_repository_test.dart` |
| Memory leak | leak tracker Flutter (`LeakTesting.enable()`) | `test/leak/memory_leak_test.dart` |

Ringkasan tabel dibuat dengan `dart run tool/perf_report.dart <folder>`. Data mentah ada di [`profiling/`](profiling/).

### Aturan agar hasilnya bukan placebo

1. **Skenario identik** untuk sebelum dan sesudah (satu file test yang sama).
2. **Bergantian**: lama, baru, lama, baru, lama. Kondisi emulator (panas, beban background) memengaruhi kedua versi secara setara.
3. **Build bersih** di setiap run (hapus `.dart_tool/flutter_build` dan `build/app/intermediates/flutter`), lalu **verifikasi isi APK**: string `_limit` muncul 2x di APK lama dan 3x di APK baru.
4. **Kelompok kontrol**: kode skenario *scroll* tidak diubah, sehingga selisih di sana = besarnya noise.
5. Dilaporkan **rata-rata dan rentang**, bukan satu run terbaik.

### Pelajaran: percobaan pengukuran pertama tidak valid

| Percobaan | Hasil | Kenapa tidak dipakai |
|---|---|---|
| Sebelum (2 run) lalu sesudah (2 run), berurutan | Detail "69 ms -> 28 ms" (2,5x lebih cepat) | Kode lama yang diukur ulang belakangan juga 33 ms. Emulator sekadar lebih cepat di run berikutnya, jadi perbedaannya **placebo**. |
| Bergantian, tanpa build bersih | Lama dan baru hampir identik | Build hanya 5-13 detik (build sungguhan 57-96 detik): Flutter memakai **binary lama**, jadi kemungkinan kedua versi menjalankan kode yang sama. |
| Leak test tanpa `LeakTesting.enable()` | Lolos | Kontrol negatif (menghapus `dispose()`) tetap lolos, berarti leak tracker **tidak aktif**. |
| `debugProfileBuildsEnabled` untuk menghitung rebuild | `NoteTile` = 0 | Tidak mencatat semua build, dan menambah beban sehingga frame time terlihat lebih buruk. Diganti `debugOnRebuildDirtyWidget`. |

Hanya data dari percobaan yang valid yang dipakai di bawah ini.

---

## 2. Baseline (sebelum) vs sesudah

Rata-rata (rentang). Sebelum = 3 run, sesudah = 2 run, semuanya build bersih dan bergantian. Satuan ms kecuali disebut lain.

### Skenario detail (buka detail -> kembali, 5x)

| Metrik | Sebelum | Sesudah |
|---|---|---|
| Frame | 61 (59-64) | 59 (56-62) |
| Build rata-rata | 25,7 (22,9-29,9) | **21,1** (20,7-21,5) |
| Build p90 | 62,3 (52,7-73,6) | **48,4** (47,0-49,9) |
| Build terburuk | 143,2 (100,0-215,3) | **109,8** (107,4-112,2) |
| Jank build (>16 ms) | 28,7 (26-32) | 26,0 (25-27) |
| **Waktu GC di UI thread** | **78,5** (62,7-101,2) | **24,9** (22,3-27,5) |

### Skenario search (mengetik `belanja 1` huruf per huruf)

| Metrik | Sebelum | Sesudah |
|---|---|---|
| Frame | 29 (26-31) | 28 (24-32) |
| Build rata-rata | 7,5 (7,1-7,7) | 10,9 (8,0-13,8) |
| Build p90 | 19,9 (18,9-21,8) | 23,5 (20,4-26,7) |
| Build terburuk | 29,3 (22,6-35,3) | 79,5 (40,4-118,5) |
| Jank build | 4,7 (4-5) | 5,5 (3-8) |
| Waktu GC | 104,3 (15,2-176,4) | 88,0 (87,1-88,8) |

### Skenario scroll (kontrol, kode tidak diubah)

| Metrik | Sebelum | Sesudah |
|---|---|---|
| Build rata-rata | 4,5 (4,3-4,8) | 5,0 (4,8-5,2) |
| Jank build | 4,0 (3-5) | 7,5 (6-9) |
| Raster rata-rata | 34,3 | 36,2 |

Selisih sekitar 10-20% di sini, padahal kodenya sama, menunjukkan **besarnya noise emulator**. Perbedaan lain yang lebih kecil dari itu tidak dianggap bermakna.

### Micro-benchmark di perangkat (3 putaran, 1 run)

| Operasi (2.000 catatan) | Lama | Baru |
|---|---|---|
| Filter per ketikan | 0,97 / 0,91 / 0,90 | **0,57 / 0,53 / 0,54** |
| Membangun indeks (sekali per perubahan data) | - | 0,50 / 0,51 / 0,50 |
| Query untuk halaman detail | 53,9 / 33,4 / 34,9 | **3,8 / 3,9 / 3,9** |

### Metrik deterministik (tidak terpengaruh noise)

| Metrik | Sebelum | Sesudah |
|---|---|---|
| Rebuild saat mengetik `belanja` (7 huruf): `NotesPage` / `AppBar` / `Badge` / `TextField` / `NoteTile` | 7 / 7 / 7 / 7 / 77 | **0 / 0 / 0 / 1 / 11** |
| Rebuild saat mengetik `belanja 1` (9 huruf) | 9 / 9 / 9 / 9 / 88 | **0 / 0 / 0 / 1 / 0** |
| Filter dijalankan per 7 ketikan cepat | 7x | **1x** (debounce 250 ms) |
| Request jaringan saat halaman posts dibuka 5x dalam 5 menit | 5 | **1** |
| Payload posts | 27.520 byte (100 item, 90 dibuang) | **2.726 byte** (10 item) |
| UI menerima data posts segar | Tidak (perlu buka ulang) | **Ya** (stale-while-revalidate) |
| Objek bocor (navigasi 5x bolak-balik) | `GoRouterDelegate`, `GoRouteInformationProvider` | **0** |

---

## 3. Optimasi yang diterapkan

| # | Optimasi (teknik codelab) | Alasan dipilih (temuan) | File |
|---|---|---|---|
| 1 | **Ekstrak widget + Riverpod `select`**: `NotesPage` jadi `StatelessWidget` tanpa `watch`; `DirtyBadge`, `SearchBox`, `NotesList` terpisah; badge memakai `select((a) => a.value ?? 0)` | Temuan 1 | `lib/pages/notes_page.dart` |
| 2 | **Debounce search 250 ms**, ikon clear memakai `ValueListenableBuilder` | Temuan 1 & 2 | `lib/pages/notes_page.dart` |
| 3 | **Indeks pencarian** (huruf kecil dihitung sekali per perubahan data), hasilnya dibuktikan identik dengan `filterNotes` lama | Temuan 2 | `lib/domain/usecases/filter_notes_usecase.dart`, `test/search_index_test.dart` |
| 4 | **Query detail `WHERE id = ? LIMIT 1`** | Temuan 3 | `lib/data/repositories/note_repository.dart` |
| 5 | **Repository cache stale-while-revalidate**: satu `Dio` dengan timeout, refresh maks 1x per 5 menit (tombol refresh tetap memaksa), `?_limit=10`, UI diperbarui saat data segar datang | Temuan 4 | `lib/data/posts_repository.dart`, `lib/data/providers.dart` |
| 6 | **`dispose()` yang benar**: `ref.onDispose(router.dispose)`; `Timer` debounce dibatalkan di `dispose()` | Temuan 5 | `lib/router/app_router.dart`, `lib/pages/notes_page.dart` |

---

## 4. Interpretasi jujur

- **Detail: membaik, dan dampak terbesar ada di GC.** Waktu GC turun dari sekitar 78 ms ke 25 ms, dan rentangnya tidak tumpang tindih. Build p90 turun dari 62 ms ke 48 ms. Query detail sendiri 9x lebih cepat (sekitar 35 ms menjadi 3,9 ms). Efeknya pada frame time lebih kecil dari angka itu karena `noteDetailProvider` adalah provider `family` yang menyimpan hasil per id: di skenario ini query hanya berjalan saat catatan pertama kali dibuka.
- **Search: tidak ada perbaikan frame time yang terukur, malah frame terburuk naik.** Filter lama pun hanya 0,93 ms per ketikan, sedangkan satu frame di emulator 7-14 ms (didominasi `TextField` dan render). Debounce membuat pekerjaan menumpuk di satu frame setelah pengguna berhenti mengetik (frame terburuk 40-118 ms) dan menambah jeda 250 ms sebelum hasil muncul. Yang terbukti hanya pengurangan rebuild dan CPU, bukan kelancaran yang terasa.
- **Scroll tidak diubah.** List sudah memakai `ListView.builder`.
- **Raster jank tinggi di semua skenario** adalah keterbatasan GPU emulator. Pengukuran raster yang bermakna perlu HP fisik.

---

## 5. Screenshot

| File | Isi |
|---|---|
| `screenshots/before-profile.png` | Flame chart skenario detail, kode lama (`profiling/timeline/before-detail.timeline.json.gz`) |
| `screenshots/after-profile.png` | Flame chart skenario detail, kode baru (`profiling/timeline/after-detail.timeline.json.gz`) |

Cara membuka: [ui.perfetto.dev](https://ui.perfetto.dev) -> *Open trace file* -> pilih file `.json.gz` (ekstrak dulu bila diminta) -> zoom ke frame panjang di track UI thread.
