# Week 8: Mid Project Review & Code Review

**Terakhir diperbarui**: 2 November 2026  
**Status**: ✅ Selesai

---

## Status Paruh Semester

Repository ini berisi portfolio Flutter Semester 5, Minggu 1–8. Fokus Week 8 adalah **disiplin kolaborasi profesional**: Git Flow, Pull Request, Code Review, CI/CD, dan AI-assisted review.

---

## Ringkasan Eksekutif

| Project | Path | Status |
|---------|------|--------|
| Week 5: Offline Notes (SQLite) | `05-week-5-local-storage-offline-first/` | ✅ Selesai |
| Week 6: Auth & FCM | `06-week-6-authentication-security-fcm/` | ✅ Selesai |
| Week 7: Clean Architecture | `07-week-7-clean-architecture/` | ✅ Selesai |
| Week 8: Mid Review | `08-week-8-mid-project-review/` | ✅ Selesai |

---

## Fitur Paruh Semester

### Week 5 — Offline Notes (SQLite)
- Local CRUD dengan `sqflite`
- Offline-first pattern
- Riverpod state management

### Week 6 — Campus Notify (Auth + FCM)
- JWT Authentication
- Token management dengan `flutter_secure_storage`
- Firebase Cloud Messaging (push notifications)
- Protected routes dengan GoRouter

### Week 7 — Clean Architecture Refactor
- Struktur feature-first: `lib/features/{auth,announcements,messaging}/`
- Layer: `presentation → domain ← data`
- Domain layer steril (zero import Flutter/Dio/SQLite)
- Riverpod sebagai DI
- Unit test use case dengan fake repository

---

## Tech Stack

| Layer | Teknologi |
|-------|-----------|
| Presentation | Flutter, Riverpod, GoRouter |
| Domain | Pure Dart (no framework) |
| Data | Dio, sqflite, flutter_secure_storage, Firebase |
| Testing | flutter_test, FakeRepository pattern |
| CI/CD | GitHub Actions |

---

## Arsitektur (Week 7)

```
presentation → domain ← data
     ↓              ↓         ↓
  Widget         Entity    Model
  Notifier       UseCase   RepoImpl
  Provider       RepoIF    DataSource
```

### Struktur Folder
```
lib/
├── core/
│   └── failures/failures.dart      # Failure hierarchy (pure Dart)
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/auth_session.dart
│   │   │   ├── repositories/auth_repository.dart  ← interface
│   │   │   └── usecases/login_usecase.dart
│   │   ├── data/
│   │   │   ├── datasources/token_store.dart
│   │   │   └── repositories/auth_repository_impl.dart
│   │   └── presentation/
│   │       ├── pages/login_page.dart
│   │       └── providers/auth_providers.dart
│   ├── announcements/
│   │   └── presentation/pages/...
│   └── messaging/
│       └── data/repositories/push_repository_impl.dart
└── shared/
    └── network/api_client.dart
```

---

## Peta Issue & Pull Request (Week 8)

### Issues
| # | Judul | Status |
|---|-------|--------|
| #1 | Setup develop branch dan Git Flow | ✅ Done |
| #2 | Tambah CI/CD GitHub Actions | ✅ Done |
| #3 | Dokumentasi mid review dan checklist | ✅ Done |
| #4 | AI review dan keputusan final | ✅ Done |

### Pull Requests
| PR | Judul | Branch | Target | Status |
|----|-------|--------|--------|--------|
| #1 | `feat(docs): tambah dokumentasi mid review dan CI workflow week 8` | `feat/week8-mid-review-docs` | `develop` | ✅ Merged |

---

## Bukti Mesin Hijau

### flutter analyze
```
Analyzing campus_notify...
No issues found!
```
> ✅ 0 issues

### dart format
```
Formatted 0 files (exit code 0)
```
> ✅ Semua file sudah terformat

### flutter test
```
00:00 +6: All tests passed!
```
> ✅ 6/6 tests passed:
> - `routeFromMessage menangani route kosong dan tanpa slash`
> - `data payload membawa id pengumuman`
> - `provider auth membaca status login dari token`
> - `refresh gagal -> sesi dibersihkan (paksa login ulang)`
> - `LoginUseCase sukses mengembalikan session`
> - `LoginUseCase gagal mengembalikan failure tanpa exception`

---

## Git Flow yang Diterapkan

```
main      → production-ready, hanya via PR
  ↑
develop   → integrasi fitur mingguan
  ↑
feature/* → kerja harian, < 3 hari
fix/*     → perbaikan cepat + test
```

### Commit Messages (Conventional Commits)
Format: `<type>(<scope>): <deskripsi singkat>`

Contoh dari project ini:
```
feat(docs): tambah dokumentasi mid review dan CI workflow week 8
fix(test): ganti UnimplementedError dengan Failure di FakeRepository
ci: tambah GitHub Actions workflow untuk flutter analyze dan test
```

---

## Cara Menjalankan

### Prerequisites
- Flutter SDK >= 3.24.5
- Dart SDK >= 3.5.4
- Git (user.name dan user.email terkonfigurasi)

### Week 7 (Recommended — sudah Clean Architecture)
```bash
cd 07-week-7-clean-architecture
flutter pub get
flutter test           # pastikan semua test hijau
flutter analyze        # pastikan 0 issues
flutter run            # gunakan emulator Android (FCM memerlukan Android)
```

### Firebase Setup (Week 6 & 7)
1. Download `google-services.json` dari Firebase Console
2. Letakkan di `android/app/`
3. Jalankan dengan `flutter run`

---

## Dokumentasi Lengkap

| Dokumen | Isi |
|---------|-----|
| [`docs/review-checklist.md`](docs/review-checklist.md) | Audit commit, tabel before/after, checklist kesiapan mid-semester |
| [`docs/ai-review-vs-keputusan.md`](docs/ai-review-vs-keputusan.md) | 5 temuan AI + keputusan final + bukti verifikasi |
| [`docs/refleksi.md`](docs/refleksi.md) | Jawaban 4 pertanyaan refleksi codelab |
| [`docs/pr-template.md`](docs/pr-template.md) | Template Pull Request |

---

## Hasil yang Dicapai (Week 1–8)

| Minggu | Topik | Pencapaian |
|--------|-------|------------|
| 1 | Flutter Basics | Profile app, widget dasar |
| 2 | Declarative UI | Responsive design, layout |
| 3 | State Management | Riverpod, AsyncValue, GoRouter |
| 4 | Networking | Dio, REST API, repository pattern |
| 5 | Local Storage | SQLite offline-first |
| 6 | Auth & FCM | JWT, token management, push notifications |
| 7 | Clean Architecture | Feature-first, dependency rule, unit test |
| 8 | Mid Review | Git Flow, PR, code review, CI/CD |

---

## Informasi Pengembang

**Nama**: Hafis  
**NIM**: 254107023005  
**Program**: Mobile Development Course  
**Semester**: 5  
**Institusi**: JTI Polinema
