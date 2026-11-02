# Screenshots - Week 8

## 📸 Documentation Screenshots

### Git Workflow

#### 1. Git Log - Commit History
**File**: `git-log-before.png`  
**Description**: Screenshot dari `git log --oneline -15` menunjukkan commit history sebelum implement Git Flow

**Content**:
```
24a4885 feat: tugas minggu 7 refactor clean architecture
ae68215 selesaikan modul 6: integrasi fcm, route, dan dokumentasi
de36032 menyelesaikan tugas praktikum week 5 local storage
...
```

#### 2. Git Branches
**File**: `git-branches-before.png`  
**Description**: Screenshot dari `git branch -a` menunjukkan hanya ada main branch

**Content**:
```
* main
  remotes/origin/main
```

#### 3. Git Flow After Implementation
**File**: `git-branches-after.png`  
**Description**: Screenshot setelah setup develop dan feature branches

**Expected Content**:
```
  develop
* feature/setup-git-flow
  main
  remotes/origin/develop
  remotes/origin/main
```

---

### Static Analysis

#### 4. Flutter Analyze Results
**File**: `flutter-analyze-results.png`  
**Description**: Screenshot dari `flutter analyze` output

**Content**:
```
Analyzing 07-week-7-clean-architecture...
No issues found! (ran in 50.2s)
```

#### 5. Dart Format Check
**File**: `dart-format-check.png`  
**Description**: Screenshot dari `dart format --set-exit-if-changed lib test`

**Content**:
```
Formatted 17 files (10 changed) in 1.28 seconds.
```

#### 6. Flutter Test Results
**File**: `flutter-test-results.png`  
**Description**: Screenshot dari `flutter test` showing all tests pass

**Content**:
```
00:05 +6: All tests passed!
```

#### 7. Architecture Compliance Check
**File**: `grep-domain-clean.png`  
**Description**: Screenshot dari grep commands verifying domain layer purity

**Content**:
```bash
$ grep -r "import 'package:flutter" lib/features/*/domain/
✅ Domain layer bersih - tidak ada import Flutter

$ grep -r "import 'package:dio" lib/features/*/domain/
✅ Domain layer bersih - tidak ada import Dio
```

---

### GitHub Setup

#### 8. GitHub Actions Workflow
**File**: `github-actions-ci.png`  
**Description**: Screenshot dari GitHub Actions tab showing CI workflow

**Expected Content**:
- Workflow name: Flutter CI
- Status: ✅ Passing
- Steps: Analyze, Format, Test

#### 9. Pull Request Example
**File**: `pr-example.png`  
**Description**: Screenshot dari first PR dengan proper template

**Expected Content**:
- Title: `feat: setup git flow and branch strategy`
- Description: Menggunakan PR template
- Checks: CI passing
- Review: Waiting for review

#### 10. Branch Protection Rules
**File**: `branch-protection.png`  
**Description**: Screenshot dari GitHub branch protection settings

**Expected Content**:
- Branch: `develop`
- Require PR reviews: ✅
- Require status checks: ✅
- Status: `Flutter CI / Verify Code Quality`

---

### Code Review

#### 11. Review Checklist in Action
**File**: `review-checklist-use.png`  
**Description**: Screenshot menggunakan review checklist saat review PR

**Expected Content**:
- Checklist printed di PR review comment
- Items checked/unchecked
- Comments pada specific lines

#### 12. AI Review Output
**File**: `ai-review-output.png`  
**Description**: Screenshot dari AI review suggestions

**Expected Content**:
- AI prompt used
- 5 temuan dengan level (blocker/major/minor)
- Suggested fixes

---

### Implementation Progress

#### 13. VS Code - Project Structure
**File**: `vscode-structure.png`  
**Description**: Screenshot dari VS Code showing week-8 folder structure

**Content**:
```
08-week-8-mid-project-review/
├── docs/
│   ├── review-checklist.md
│   ├── static-analysis-report.md
│   ├── ai-review-vs-keputusan.md
│   ├── pr-template.md
│   ├── github-actions-ci.yml
│   ├── refleksi.md
│   ├── issue-examples.md
│   └── SUMMARY.md
├── screenshots/
└── README.md
```

#### 14. Week 7 App Running
**File**: `app-running.png`  
**Description**: Screenshot dari aplikasi Week 7 running successfully

**Expected Content**:
- Login screen atau
- Announcements screen
- No errors in console

---

## 📝 How to Capture Screenshots

### Windows (PowerShell)
```powershell
# Full screen
Win + PrtScn

# Snipping Tool
Win + Shift + S

# Save to screenshots/ folder with descriptive name
```

### macOS
```bash
# Full screen
Cmd + Shift + 3

# Selection
Cmd + Shift + 4
```

### VS Code Terminal
1. Ensure terminal output visible
2. Use Snipping Tool to capture
3. Save with appropriate name

---

## 🎯 Screenshot Checklist

### Praktikum 1: Git Hygiene ✅
- [ ] `git-log-before.png` - Commit history
- [ ] `git-branches-before.png` - Initial branch state
- [ ] `git-branches-after.png` - After Git Flow setup

### Praktikum 3: Static Analysis ✅
- [ ] `flutter-analyze-results.png` - Analyze output
- [ ] `dart-format-check.png` - Format check
- [ ] `flutter-test-results.png` - Test results
- [ ] `grep-domain-clean.png` - Architecture verification

### GitHub Setup 📝
- [ ] `github-actions-ci.png` - CI workflow
- [ ] `pr-example.png` - First PR
- [ ] `branch-protection.png` - Protection rules

### Code Review 📝
- [ ] `review-checklist-use.png` - Checklist in action
- [ ] `ai-review-output.png` - AI suggestions

### General 📝
- [ ] `vscode-structure.png` - Project structure
- [ ] `app-running.png` - App running

---

## 💡 Screenshot Tips

### DO ✅
- Use high resolution (at least 1920x1080)
- Show full context (entire terminal output)
- Use light theme for better readability in print
- Crop to relevant area (remove unnecessary desktop)
- Annotate if needed (arrows, highlights)

### DON'T ❌
- Don't capture sensitive data (tokens, passwords)
- Don't include personal desktop clutter
- Don't use low resolution
- Don't capture blurry/unclear text

---

## 📦 Placeholder Status

**Current Status**: 📝 **README ONLY**

Screenshots akan ditambahkan saat:
1. Implement Git Flow (capture before/after)
2. Run static analysis (capture terminal output)
3. Setup GitHub (capture CI and PR)
4. Do code review (capture checklist usage)

**Estimated Time**: 30-60 minutes untuk capture semua screenshots

---

**Note**: This README serves as a guide for what screenshots to capture. Actual screenshots akan ditambahkan during implementation phase.

---

**Last Updated**: 19 Oktober 2026  
**Status**: 📝 Guide ready, awaiting screenshots
