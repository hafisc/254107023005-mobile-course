# Review Checklist - Week 8

**Terakhir diperbarui**: 2 November 2026  
**Status**: ✅ Praktikum 1 & 3 Selesai

---

## Praktikum 1: Hygiene Branch dan Commit

### 1. Audit Riwayat Commit

```
# Hasil git log --oneline -15
24a4885 feat: tugas minggu 7 refactor clean architecture auth dan pengumuman
ae68215 selesaikan modul 6: integrasi fcm, route, dan dokumentasi readme
de36032 menyelesaikan tugas praktikum week 5 local storage dan offline first dengan sqlite
3cd1f4e menyelesaikan tugas praktikum week 4 networking rest api dengan dio dan riverpod
cf15e31 feat: kerjain tugas praktikum minggu 3 (todo app + riverpod)
2b9c390 menyelesaikan tugas praktikum week 2 declarative ui & responsive design
8b6e81c fix bug readme
1b58731 feat: create week 1 Flutter profile app
58aa08d feat: create week 1 Flutter profile app
1cc2731 first commit
585f9d5 first commit

# Hasil git branch -a
* main
  remotes/origin/main
```

### 2. Masalah yang Ditemukan

| # | Masalah | Dampak |
|---|---------|--------|
| 1 | Tidak ada branch `develop` — semua commit langsung ke `main` | Tidak ada safety net; production branch tidak terlindungi |
| 2 | Beberapa commit message tidak mengikuti Conventional Commits | Sulit generate changelog otomatis, sulit filter commit |
| 3 | Dua commit `first commit` dan dua `feat: create week 1` | History membingungkan, kemungkinan push duplikat |
| 4 | Belum ada branch `feature/*` atau `fix/*` | Tidak ada workflow PR yang benar |

### 3. Tabel Before/After Commit Messages

| No | Before (Buruk) | After (Baik) | Alasan |
|----|----------------|--------------|--------|
| 1 | `selesaikan modul 6: integrasi fcm, route, dan dokumentasi readme` | `feat(fcm): integrasi Firebase Cloud Messaging + protected routes` | Terlalu panjang; "selesaikan" bukan tipe commit valid; harusnya pisah commit docs dan feat |
| 2 | `menyelesaikan tugas praktikum week 5 local storage dan offline first dengan sqlite` | `feat(storage): implementasi SQLite offline notes dengan sqflite` | Kalimat status bukan deskripsi perubahan; tidak ada scope; terlalu panjang |
| 3 | `fix bug readme` | `docs(readme): perbaiki link instalasi yang broken` | "bug" tidak spesifik; tipe harusnya `docs`; harus jelas apa yang diperbaiki |
| 4 | `feat: kerjain tugas praktikum minggu 3 (todo app + riverpod)` | `feat(todo): implementasi todo app dengan Riverpod state management` | "kerjain" tidak profesional; tidak ada scope; deskripsi harus tentang perubahan, bukan konteks tugas |
| 5 | `first commit` (duplikat) | `chore: initial project setup dan struktur folder` | Tidak deskriptif; duplikat tidak boleh; tipe `chore` lebih tepat |

---

## Praktikum 2: Pull Request Workflow

### Setup Branch Develop

Branch `develop` dibuat dari `main` dan di-push ke remote:
```bash
git checkout -b develop
git push -u origin develop
```

### PR yang Dibuat

**Branch**: `feat/week8-mid-review-docs` → `develop`

**Judul PR**: `feat(docs): tambah dokumentasi mid review dan CI workflow week 8`

**Template PR**:
```
Masalah: Belum ada dokumentasi review checklist, AI review, dan CI/CD untuk Week 8.
Solusi: Tambah docs/review-checklist.md, docs/ai-review-vs-keputusan.md, dan .github/workflows/ci.yml.
Cara uji: Buka PR di GitHub, pastikan CI berjalan; baca docs/ untuk verifikasi kelengkapan.
Closes #1
```

---

## Praktikum 3: Static Analysis & Mid Review

### 1. Hasil flutter analyze

```bash
# Dijalankan di: 07-week-7-clean-architecture/
flutter analyze
```

> **Hasil**: Analyzing... No issues found! ✅

### 2. Hasil dart format

```bash
# Dijalankan di: 07-week-7-clean-architecture/
dart format --set-exit-if-changed .
```

> **Hasil**: Formatted 0 files. Exit code 0. ✅

### 3. Hasil flutter test

```bash
# Dijalankan di: 07-week-7-clean-architecture/
flutter test
```

> **Hasil**:
> ```
> 00:00 +6: All tests passed!
> ```
> Test yang lulus (6/6):
> - `routeFromMessage menangani route kosong dan tanpa slash`
> - `data payload membawa id pengumuman`
> - `provider auth membaca status login dari token`
> - `refresh gagal -> sesi dibersihkan (paksa login ulang)`
> - `LoginUseCase sukses mengembalikan session`
> - `LoginUseCase gagal mengembalikan failure tanpa exception`

---

## Nilai Kesiapan Tengah Semester

| Kriteria | Status | Bukti |
|----------|--------|-------|
| Struktur feature-first terbukti | ✅ | `lib/features/{auth,announcements,messaging}/` |
| Sterilitas domain (tiga grep) | ✅ | Lihat bagian grep di bawah |
| `flutter analyze` bersih | ✅ | No issues found |
| `flutter test` hijau | ✅ | 6/6 tests passed |
| PR kecil dibuat | ✅ | Branch `feat/week8-mid-review-docs` |
| Commit message konvensional | ✅ | Tabel before/after di atas |
| README + screenshot + cara menjalankan | ✅ | README.md semua week lengkap |
| Komentar review AI ditindaklanjuti | ✅ | Lihat `docs/ai-review-vs-keputusan.md` |

### Bukti Sterilitas Tiga Grep

```bash
# 1. Widget/framework tidak masuk domain
grep -r "import 'package:flutter" 07-week-7-clean-architecture/lib/features/*/domain/
# → 0 hasil ✅

# 2. Dio tidak masuk domain atau core
grep -r "import 'package:dio" 07-week-7-clean-architecture/lib/features/*/domain/ 07-week-7-clean-architecture/lib/core/
# → 0 hasil ✅

# 3. Tidak ada instansiasi manual di presentation selain providers
grep -r "Repository(" 07-week-7-clean-architecture/lib/features/*/presentation/
# → 0 hasil ✅
```

---

## CI/CD dengan GitHub Actions

File `.github/workflows/ci.yml` telah dibuat dengan steps:
1. `flutter pub get`
2. `dart format --set-exit-if-changed .`
3. `flutter analyze --fatal-infos`
4. `flutter test --reporter=expanded`

PR yang kotor (analyze gagal atau test merah) akan ditolak mesin secara otomatis sebelum dibaca reviewer.

---

## Ringkasan Status

- [x] Audit commit history selesai
- [x] Tabel before/after commit messages (5 contoh)
- [x] Branch `develop` dibuat dan di-push
- [x] Branch `feat/week8-mid-review-docs` dibuat
- [x] CI workflow dibuat (`.github/workflows/ci.yml`)
- [x] `flutter analyze` bersih
- [x] `flutter test` hijau
- [x] Sterilitas domain terverifikasi dengan grep
- [x] AI review 5 temuan + keputusan terdokumentasi
- [x] Refleksi ditulis di `docs/refleksi.md`
