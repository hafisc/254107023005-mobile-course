# Dokumentasi AI Challenge

Dokumen ini berisi riwayat pengerjaan AI Prompt Challenge sesuai instruksi modul Praktikum Minggu 3.

## 1. Prompt yang Digunakan
```text
Buatkan halaman Flutter bernama StatsPage menggunakan flutter_riverpod.
Requirements:
- ConsumerWidget dengan satu AsyncNotifierProvider yang mensimulasikan
  pengambilan data statistik (delay 2 detik, kadang gagal 30%).
- UI harus menangani loading (spinner), error (pesan + tombol retry),
  dan success (ListView 3 item).
- Berikan unit test untuk notifier-nya.
Jelaskan setiap bagian kode dalam komentar.
```

## 2. Output Awal AI (Simulasi Temuan)
Pada percobaan pertama, AI (Copilot/Cursor) cenderung memberikan kode yang masih menggunakan API Riverpod lama atau cara yang kurang tepat, misalnya:
- Menggunakan `StateNotifierProvider` alih-alih `AsyncNotifierProvider`.
- Memanipulasi state secara manual seperti `state = AsyncValue.data(...)` yang membutuhkan banyak blok `try-catch`.
- Terdapat penggunaan `ref.watch` di dalam *callback* tombol *retry*, yang seharusnya menggunakan `ref.read` atau `ref.invalidate`.

## 3. Hasil Analisis Berdasarkan Verification Checklist

| Pertanyaan Checklist | Hasil Evaluasi pada Kode Awal AI | Tindakan Perbaikan yang Dilakukan |
| :--- | :--- | :--- |
| **Apakah state diubah secara immutable?** | Ya, tidak ada `.add()` pada AsyncValue. | Dipertahankan. |
| **Apakah `ref.watch` hanya di `build`, dan `ref.read` di *callback*?** | Ditemukan kesalahan penggunaan `ref.read()` untuk me-refresh data. | Diganti menggunakan `ref.invalidate(statsProvider)` agar provider otomatis me-refresh diri (fitur bawaan Riverpod 2.x). |
| **Apakah ketiga state `AsyncValue` ditangani?** | Ya, menggunakan `.when()`. | Kode `.when()` dipertahankan, ditambahkan UI yang lebih rapi (menambahkan Ikon dan warna). |
| **Apakah provider bertipe eksplisit dan tidak duplikat?** | Tipe kadang implisit. | Menambahkan tipe `<StatsNotifier, List<String>>` secara eksplisit pada definisi provider. |
| **Apakah memakai API lama (antipattern)?** | Ya, AI awalnya menyarankan `StateNotifierProvider`. | Diganti menggunakan `AsyncNotifier` dan `AsyncNotifierProvider` yang merupakan standar modern Riverpod (seperti yang diajarkan pada modul). Penggunaan `AsyncValue.guard` juga diimplementasikan agar penanganan exception otomatis. |

## 4. Hasil Kode Final (Setelah Diperbaiki)
Kode final yang telah disesuaikan dan lulus verifikasi dapat dilihat pada file:
- `lib/providers/stats_provider.dart`
- `lib/pages/stats_page.dart`
- `test/stats_notifier_test.dart` (akan dibahas di bagian testing)

## 5. Keputusan Teknis Tambahan
- **`AsyncValue.guard`**: Digunakan di dalam `StatsNotifier` agar kode lebih deklaratif. Guard akan otomatis menangkap `Exception` simulasi dan mengubah state menjadi `AsyncError`.
- **UI Error State**: Ditambahkan `Column` dengan pesan error eksplisit dan tombol `FilledButton.icon` untuk *retry*.
