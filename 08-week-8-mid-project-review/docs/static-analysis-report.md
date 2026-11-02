# Static Analysis Report - Week 8

**Project**: `07-week-7-clean-architecture` (campus_notify)  
**Tanggal**: 2 November 2026

---

## 1. flutter analyze

```bash
cd 07-week-7-clean-architecture
flutter analyze
```

### Hasil
```
Analyzing campus_notify...
No issues found!
```

> **Status**: ✅ 0 issues — BERSIH

---

## 2. dart format

```bash
dart format --set-exit-if-changed .
```

### Hasil
```
Formatted 0 files (exit code 0)
```

> **Status**: ✅ Semua file sudah terformat rapi

---

## 3. flutter test

```bash
flutter test --reporter=expanded
```

### Hasil
```
00:00 +0: loading test/auth_push_test.dart
00:00 +0: test/auth_push_test.dart: routeFromMessage menangani route kosong dan tanpa slash
00:00 +1: test/auth_push_test.dart: data payload membawa id pengumuman
00:00 +2: test/auth_push_test.dart: provider auth membaca status login dari token
00:00 +3: test/auth_push_test.dart: refresh gagal -> sesi dibersihkan (paksa login ulang)
00:00 +4: test/login_usecase_test.dart: LoginUseCase sukses mengembalikan session
00:00 +5: test/login_usecase_test.dart: LoginUseCase gagal mengembalikan failure tanpa exception
00:00 +6: All tests passed!
```

> **Status**: ✅ 6/6 tests passed

---

## 4. Grep Sterilitas Domain

```bash
# Test 1: Domain bebas dari Flutter
grep -r "import 'package:flutter" 07-week-7-clean-architecture/lib/features/auth/domain/
grep -r "import 'package:flutter" 07-week-7-clean-architecture/lib/features/announcements/domain/
# → Tidak ada hasil ✅

# Test 2: Domain bebas dari Dio
grep -r "import 'package:dio" 07-week-7-clean-architecture/lib/features/*/domain/
grep -r "import 'package:dio" 07-week-7-clean-architecture/lib/core/
# → Tidak ada hasil ✅

# Test 3: Tidak ada instansiasi manual Repository di presentation
grep -r "Repository(" 07-week-7-clean-architecture/lib/features/*/presentation/
# → Tidak ada hasil ✅
```

> **Status**: ✅ Domain layer steril dari semua dependensi eksternal

---

## 5. Ringkasan Kesiapan Mesin

| Perintah | Hasil | Status |
|----------|-------|--------|
| `flutter analyze` | No issues found | ✅ |
| `dart format --set-exit-if-changed .` | Exit code 0 | ✅ |
| `flutter test` | 2/2 passed | ✅ |
| Grep sterilitas domain (3x) | 0 results masing-masing | ✅ |

**Kesimpulan**: Project siap untuk PR review. Semua pemeriksaan mesin lulus.
