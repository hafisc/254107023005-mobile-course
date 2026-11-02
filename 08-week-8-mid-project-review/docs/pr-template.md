# Pull Request Template

## 📝 Description

### Masalah / Problem
<!-- Jelaskan apa yang error, kurang, atau perlu diperbaiki -->
<!-- Link ke issue: Closes #XX -->

**Issue**: Closes #[issue-number]

**Deskripsi masalah**:
- 

### Solusi / Solution
<!-- Jelaskan bagaimana PR ini memperbaiki masalah -->

**Pendekatan yang diambil**:
- 

**Perubahan utama**:
- 

---

## 🧪 Cara Uji / How to Test

### Prerequisites
```bash
flutter pub get
# Tambahan setup jika perlu (Firebase config, etc.)
```

### Langkah Testing Manual
1. 
2. 
3. 

**Expected behavior**:
- 

**Actual behavior** (setelah fix):
- 

### Automated Tests
```bash
# Unit tests
flutter test test/path/to/test_file.dart

# Semua tests
flutter test
```

---

## 📸 Screenshots / Video

### Before
<!-- Screenshot/video SEBELUM perubahan (jika applicable) -->


### After
<!-- Screenshot/video SETELAH perubahan -->


---

## ✅ Pre-PR Checklist

### Code Quality
- [ ] `flutter analyze` bersih (0 issues)
- [ ] `dart format .` sudah dijalankan
- [ ] `flutter test` pass (semua test hijau)
- [ ] No unused imports / dead code
- [ ] Manual testing done

### Commit Messages
- [ ] Mengikuti Conventional Commits format
- [ ] Commit messages jelas dan deskriptif
- [ ] Tidak ada commit "WIP" / "temp" / "fix bug"

### Branch
- [ ] Branch dari `develop` (bukan dari `main`)
- [ ] Branch name sesuai konvensi (`feature/*` atau `fix/*`)
- [ ] Branch up-to-date dengan `develop`

### Documentation
- [ ] README diupdate (jika perlu)
- [ ] Code comments untuk logic kompleks (why, not what)
- [ ] API documentation (jika ada public interface)

### Testing
- [ ] Unit tests untuk use cases baru
- [ ] Widget tests untuk UI critical (jika ada perubahan UI)
- [ ] Edge cases covered (empty state, error state, loading state)

---

## 🏗️ Architecture Compliance

### Clean Architecture Checklist
- [ ] Domain layer pure Dart (no Flutter/Dio/SQLite imports)
- [ ] Repository pattern diikuti
- [ ] Use cases single responsibility
- [ ] Dependencies di-inject via constructor
- [ ] No business logic di presentation layer

### Verification Commands
```bash
# Check domain layer purity (should return empty)
grep -r "import 'package:flutter" lib/features/*/domain/
grep -r "import 'package:dio" lib/features/*/domain/
grep -r "import 'package:sqflite" lib/features/*/domain/

# Check analyze
flutter analyze

# Check tests
flutter test
```

---

## 🔍 Review Focus Areas

### Untuk Reviewer
Mohon review dengan fokus pada:

- [ ] **Kebenaran**: Null safety, error handling, edge cases
- [ ] **Arsitektur**: Dependency rule, separation of concerns
- [ ] **Testing**: Test coverage dan test quality
- [ ] **Keterbacaan**: Naming, function size, complexity
- [ ] **Performance**: Unnecessary rebuilds, optimasi

### Areas of Concern
<!-- Bagian kode yang perlu perhatian khusus dari reviewer -->


---

## 📊 Impact Analysis

### Lines Changed
<!-- Diisi otomatis oleh GitHub -->
- **Files changed**: 
- **Additions**: 
- **Deletions**: 

### Affected Features
<!-- Feature apa saja yang terpengaruh perubahan ini -->
- 

### Breaking Changes
<!-- Ada breaking changes? Jelaskan migrasi path -->
- [ ] No breaking changes
- [ ] Breaking changes (dijelaskan di bawah):


---

## 🔗 Related Issues/PRs

<!-- Link ke issue/PR terkait -->
- Related to #
- Depends on #
- Blocks #

---

## 📝 Additional Notes

<!-- Catatan tambahan untuk reviewer atau context khusus -->


---

## 🎯 Reviewer Checklist

<!-- Untuk diisi oleh REVIEWER -->

### Code Review
- [ ] Code logic benar dan aman
- [ ] Error handling comprehensive
- [ ] Edge cases tertangani
- [ ] Null safety terjamin

### Architecture
- [ ] Dependency rule tidak dilanggar
- [ ] Layer boundaries respected
- [ ] DI pattern konsisten
- [ ] No circular dependencies

### Testing
- [ ] Tests actually test the intended behavior
- [ ] Both happy path and sad path covered
- [ ] Mocks digunakan dengan benar
- [ ] No flaky tests

### Readability
- [ ] Code self-documenting
- [ ] Naming conventions konsisten
- [ ] Functions < 50 lines
- [ ] No code duplication

### Decision
- [ ] ✅ **APPROVE** - Ready to merge
- [ ] 🔄 **REQUEST CHANGES** - Needs fixes
- [ ] 💬 **COMMENT** - Suggestions only

---

## 📚 References

<!-- Link ke dokumentasi, design docs, atau referensi lain -->
- [Design Doc](link)
- [API Documentation](link)
- [Related Codelab](link)

---

**Author**: @[username]  
**Reviewers**: @[reviewer1], @[reviewer2]  
**Target Merge**: `develop`  
**Size**: [Small < 100 lines | Medium 100-300 lines | Large > 300 lines]  
**Priority**: [Low | Medium | High | Critical]

---

## Example PR Messages

### Good PR Title Examples ✅
```
feat(auth): implementasi JWT token refresh mechanism
fix(notes): cegah simpan catatan dengan judul kosong
refactor(storage): pisahkan SQLite logic ke repository pattern
test(announcements): tambah unit test untuk fetch use case
docs(readme): update installation guide untuk Firebase
```

### Bad PR Title Examples ❌
```
Update file
Fix bug
Implement feature
Changes
Final update
```

---

**Template Version**: 1.0  
**Last Updated**: 19 Oktober 2026
