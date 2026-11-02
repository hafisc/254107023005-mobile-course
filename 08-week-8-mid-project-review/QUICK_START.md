# Quick Start Guide - Week 8 Implementation

**Estimated Time**: 2-3 hours untuk complete all steps  
**Prerequisites**: Git configured, Flutter installed, GitHub account ready

---

## 🚀 Phase 1: Setup Git Flow (30 minutes)

### Step 1: Create develop branch
```bash
# Dari root repository
cd "e:\Dokumen\Kuliah\Semester 5\Pemrograman Web\student-hafis-mobile-course"

# Pastikan main up-to-date
git checkout main
git pull origin main

# Create develop dari main
git checkout -b develop
git push -u origin develop
```

**Verify**:
```bash
git branch -a
# Should show:
#   main
# * develop
#   remotes/origin/main
#   remotes/origin/develop
```

### Step 2: Set develop as default branch di GitHub
1. Buka repository di GitHub
2. Settings → Branches
3. Default branch → Switch to `develop`
4. Confirm

**Why**: Semua PR akan target develop by default

---

## 🎨 Phase 2: Fix Code Formatting (15 minutes)

### Step 1: Create feature branch
```bash
git checkout develop
git checkout -b fix/format-code-style
```

### Step 2: Run formatter
```bash
cd "e:\Dokumen\Kuliah\Semester 5\Pemrograman Web\student-hafis-mobile-course\07-week-7-clean-architecture"

# Format all code
dart format lib test

# Verify no changes needed
dart format --set-exit-if-changed lib test
# Should exit with code 0
```

### Step 3: Commit and push
```bash
git add .
git commit -m "style: format code dengan dart format untuk konsistensi"
git push -u origin fix/format-code-style
```

**Verify**:
```bash
# Check diff
git diff develop..fix/format-code-style

# Should show formatted files:
# - lib/features/auth/presentation/pages/login_page.dart
# - lib/features/auth/data/repositories/auth_repository_impl.dart
# - ... (10 files total)
```

---

## ⚙️ Phase 3: Setup GitHub Actions CI (45 minutes)

### Step 1: Create workflow file
```bash
# Dari root repository
cd "e:\Dokumen\Kuliah\Semester 5\Pemrograman Web\student-hafis-mobile-course"

# Create directories
mkdir -p .github/workflows

# Copy CI config (simplified version)
```

Create file `.github/workflows/ci.yml`:
```yaml
name: Flutter CI

on:
  pull_request:
    branches: [ develop, main ]
  push:
    branches: [ develop, main ]

jobs:
  verify:
    name: Verify Code Quality
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.5'
          channel: 'stable'
          cache: true
      
      - name: Get dependencies
        run: |
          cd 07-week-7-clean-architecture
          flutter pub get
      
      - name: Check formatting
        run: |
          cd 07-week-7-clean-architecture
          dart format --set-exit-if-changed lib test
      
      - name: Analyze code
        run: |
          cd 07-week-7-clean-architecture
          flutter analyze --fatal-infos --fatal-warnings
      
      - name: Run tests
        run: |
          cd 07-week-7-clean-architecture
          flutter test
```

### Step 2: Commit CI config
```bash
git checkout develop
git add .github/workflows/ci.yml
git commit -m "ci: tambah GitHub Actions workflow untuk quality checks"
git push origin develop
```

### Step 3: Verify CI works
1. Buka GitHub repository
2. Klik tab "Actions"
3. Lihat workflow "Flutter CI" running
4. Wait for completion (3-5 minutes)
5. Check ✅ all steps passed

**Troubleshooting**:
- Jika CI fail, check logs di GitHub Actions
- Common issue: path ke project (adjust `cd` command)
- Fix locally, commit, push

---

## 📝 Phase 4: Open First PR (30 minutes)

### Step 1: Prepare PR dari fix/format-code-style
```bash
# Ensure branch up-to-date
git checkout fix/format-code-style
git fetch origin develop
git rebase origin/develop

# Push (may need --force if rebased)
git push origin fix/format-code-style
```

### Step 2: Open PR di GitHub
1. Buka repository di GitHub
2. Klik "Pull requests" → "New pull request"
3. Base: `develop` ← Compare: `fix/format-code-style`
4. Click "Create pull request"

### Step 3: Fill PR template
Use template dari `08-week-8-mid-project-review/docs/pr-template.md`:

```markdown
## 📝 Description

### Masalah / Problem
Static analysis menunjukkan 10 files tidak konsisten dengan dart format.

**Issue**: Closes #2

### Solusi / Solution
Format semua code dengan `dart format lib test` untuk konsistensi.

---

## 🧪 Cara Uji

```bash
cd 07-week-7-clean-architecture
dart format --set-exit-if-changed lib test
# Should exit 0
flutter analyze
# Should show 0 issues
flutter test
# Should pass all tests
```

---

## ✅ Pre-PR Checklist

- [x] `flutter analyze` bersih
- [x] `dart format` done
- [x] `flutter test` pass
- [x] Branch dari `develop`
- [x] CI checks pass

---

## 🏗️ Architecture Compliance

No architecture changes - formatting only.

---

Closes #2
```

### Step 4: Wait for CI
- CI akan run automatically
- Check status di PR page
- Semua checks harus ✅ green

### Step 5: Request Review
1. Di PR page, klik "Reviewers"
2. Tag peer reviewer atau instructor
3. Wait for feedback

---

## 🔍 Phase 5: Code Review Practice (30 minutes)

### As Reviewer:

#### Step 1: Checkout PR branch locally
```bash
git fetch origin
git checkout fix/format-code-style
```

#### Step 2: Run locally
```bash
cd 07-week-7-clean-architecture

# Verify formatting
dart format --set-exit-if-changed lib test

# Verify analyze
flutter analyze

# Verify tests
flutter test
```

#### Step 3: Review dengan checklist
Use `08-week-8-mid-project-review/docs/review-checklist.md`:

- [ ] Kebenaran: No logic changes (formatting only) ✅
- [ ] Arsitektur: No architecture impact ✅
- [ ] Testing: All tests still pass ✅
- [ ] Keterbacaan: Code more consistent ✅

#### Step 4: Leave review
1. Di PR page, klik "Files changed"
2. Review changes (should be formatting only)
3. Click "Review changes" button
4. Choose:
   - ✅ **Approve** (jika all good)
   - 💬 **Comment** (jika ada saran non-blocking)
   - 🔴 **Request changes** (jika ada masalah blocking)

**Example Approve Comment**:
```markdown
✅ APPROVE

All checks pass:
- dart format clean
- flutter analyze 0 issues
- flutter test 6/6 pass
- CI green

Formatting improves consistency. Ready to merge.
```

### As Author (responding to review):

#### If changes requested:
```bash
# Make fixes
git add .
git commit -m "fix: address review feedback"
git push origin fix/format-code-style

# Request re-review di PR page
```

#### If approved:
1. Klik "Merge pull request"
2. Choose "Squash and merge" (untuk clean history)
3. Edit commit message jika perlu
4. Confirm merge
5. Delete branch

---

## 🧹 Phase 6: Cleanup (5 minutes)

### After PR merged:

```bash
# Switch back to develop
git checkout develop
git pull origin develop

# Delete local feature branch
git branch -d fix/format-code-style

# Remote branch auto-deleted by GitHub (jika dicentang)
# Or manual:
# git push origin --delete fix/format-code-style

# Verify clean state
git branch -a
git status
```

---

## ✅ Verification Checklist

### Git Flow ✅
- [ ] `develop` branch exists
- [ ] `develop` set as default di GitHub
- [ ] `main` branch protected
- [ ] Feature branch workflow understood

### Code Quality ✅
- [ ] `flutter analyze` 0 issues
- [ ] `dart format` consistent
- [ ] `flutter test` 6/6 pass
- [ ] CI passing on all checks

### PR Workflow ✅
- [ ] PR opened dengan proper template
- [ ] CI runs automatically
- [ ] Peer review done dengan checklist
- [ ] PR merged dan branch cleaned up

### Documentation ✅
- [ ] All docs in 08-week-8-mid-project-review/ complete
- [ ] README updated dengan status
- [ ] Screenshots captured (optional)
- [ ] Refleksi done

---

## 🚨 Common Issues & Solutions

### Issue 1: CI fails dengan path error
**Error**: `Directory not found: 07-week-7-clean-architecture`

**Solution**: Update workflow file path
```yaml
- name: Get dependencies
  run: |
    cd 07-week-7-clean-architecture  # Adjust this path
    flutter pub get
```

### Issue 2: Format check fails in CI but passes locally
**Error**: `Files need formatting`

**Solution**: 
```bash
# Re-run formatter
dart format lib test

# Commit changes
git add .
git commit --amend --no-edit
git push --force origin fix/format-code-style
```

### Issue 3: Permission error saat setup branch protection
**Error**: `You don't have permission`

**Solution**: Need admin access atau ask instructor untuk setup

### Issue 4: CI timeout (takes > 10 minutes)
**Error**: `Job exceeded maximum time`

**Solution**: Add timeout dan cache
```yaml
jobs:
  verify:
    timeout-minutes: 10
    steps:
      - uses: subosito/flutter-action@v2
        with:
          cache: true  # Enable caching
```

### Issue 5: Merge conflict
**Error**: `This branch has conflicts`

**Solution**:
```bash
git checkout fix/format-code-style
git fetch origin develop
git rebase origin/develop
# Resolve conflicts manually
git add .
git rebase --continue
git push --force origin fix/format-code-style
```

---

## 📊 Success Metrics

After completing this quick start, you should have:

- ✅ Git Flow working (develop, feature branches)
- ✅ CI/CD running (automated quality checks)
- ✅ First PR merged (with proper review)
- ✅ Clean code (0 analyze issues, formatted)
- ✅ Documentation complete (Week 8 deliverables)

**Confidence Level**: 🟢 Ready untuk advanced workflows

---

## 🎯 Next Steps (Beyond Quick Start)

### Short-term (This Week)
1. Create issue #3: Add widget tests
2. Open PR untuk implement typed error handling
3. Practice review dengan peer

### Medium-term (Next Week)
4. Setup branch protection rules
5. Add more tests (target 70% coverage)
6. Improve documentation

### Long-term (Rest of Semester)
7. Maintain clean analyze (0 issues)
8. Every PR reviewed before merge
9. CI always green
10. Apply lessons ke Week 9-16

---

## 🆘 Need Help?

### Documentation References
- Git Flow: `docs/review-checklist.md` section 3
- PR Template: `docs/pr-template.md`
- CI Config: `docs/github-actions-ci.yml`
- Review Guide: `docs/refleksi.md`

### Commands Quick Reference
```bash
# Git Flow
git checkout -b feature/name   # Create feature branch
git push -u origin feature/name # Push branch

# Quality Checks
dart format lib test           # Format code
flutter analyze                # Analyze
flutter test                   # Test

# PR Workflow
git checkout develop           # Switch to develop
git merge feature/name         # Merge (or via GitHub)
git branch -d feature/name     # Delete local branch
```

---

**Quick Start Status**: ✅ Ready to Execute  
**Estimated Total Time**: 2-3 hours  
**Difficulty**: 🟢 Beginner-friendly with step-by-step guide

**Let's Go!** 🚀
