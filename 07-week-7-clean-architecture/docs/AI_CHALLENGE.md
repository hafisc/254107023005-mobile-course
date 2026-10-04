# AI Challenge & Refactoring Log (Week 7)

## Prompt yang Digunakan
> "Project Flutter saya: campus_notify (auth + FCM + daftar pengumuman). Kondisi kini: folder lib/{data, providers, pages, messaging}, repository tercampur dengan implementasi, widget memanggil Dio langsung. Tugas: 1. Usulkan struktur feature-first Clean Architecture (presentation/domain/data) untuk fitur auth + announcements. 2. Untuk tiap file lama, sebutkan tujuan barunya (pindah/pecah/hapus). 3. Tandai bagian yang over-engineering bila diterapkan ke CRUD sederhana, dan kapan use case benar-benar dibutuhkan vs repository langsung. 4. Tunjukkan wiring DI dengan Riverpod (tanpa package DI tambahan). Jelaskan trade-off setiap keputusan."

## Keputusan Final & Trade-off (Usulan vs Keputusan Final)

| Usulan File / Konsep | Keputusan Final | Alasan / Trade-off |
|---|---|---|
| `data/auth_repository.dart` | Dipecah menjadi `domain/repositories/auth_repository.dart` (Interface) dan `data/repositories/auth_repository_impl.dart` (Implementasi) | Memisahkan kontrak murni dart di domain dan implementasi data (bersentuhan Dio). Dependensi menjadi lebih terbalik (Dependency Inversion). |
| `data/token_store.dart` | Dipindah ke `auth/data/datasources/token_store.dart` | Membaca token dari Secure Storage merupakan urusan layer Data spesifik fitur Auth. |
| `data/api_client.dart` | Dipindah ke `shared/network/api_client.dart` | Digunakan oleh berbagai fitur, tidak boleh ada di `core/` karena `core/` harus steril dari Dio. Trade-off: menambah folder shared, namun menjaga sterilitas domain. |
| `LoginUseCase` | Dibuat di `auth/domain/usecases/login_usecase.dart` | Dibuat untuk melengkapi syarat 1 fitur terpisah secara utuh dengan use case. Ini membantu abstraksi jika di kemudian hari proses login membutuhkan banyak manipulasi repository. |
| `GetAnnouncementUseCase` (Over-engineering) | Ditolak (Tidak dibuat untuk CRUD sederhana) | Trade-off: Menghemat boilerplate code tanpa merusak aturan dependensi. Notifier langsung memanggil Repository Interface. |

## Hasil Sterilisasi Layer (Tiga Grep Verification)

1. **Presentation steril dari data mentah:**
   Hasil perintah grep `Dio|openDatabase|FlutterSecureStorage` di `presentation/` dan `pages/`: **Nol hasil**. (Semuanya dilakukan via provider & repository).
2. **Domain steril dari framework & package:**
   Hasil perintah grep `import 'package:flutter|import 'package:dio` di `domain/` dan `core/`: **Nol hasil**. (Entity dan kegagalan/failure 100% murni Dart code).
3. **Static analysis & Test:**
   `flutter analyze` = No issues found!
   `flutter test` = All tests passed!

## Kesimpulan
Arsitektur kini mengikuti standar Clean Architecture *Feature-First*. Pengujian logika domain dapat dilakukan murni tanpa memikirkan implementasi Firebase atau API.
