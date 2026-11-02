# Issue Examples & Tracking

## 📋 Issue Template

### Bug Report Template
```markdown
**Title**: [Bug] Login crashes on empty password field

**Labels**: bug, priority:high, feature:auth

**Description**:
Aplikasi crash ketika user submit form login dengan password field kosong.

**Steps to Reproduce**:
1. Buka login page
2. Isi email: "test@test.com"
3. Biarkan password kosong
4. Klik tombol "Login"
5. App crashes

**Expected Behavior**:
- Tampilkan validation error message
- Focus ke password field
- Tidak boleh crash

**Actual Behavior**:
- App crashes immediately
- Error log: `Null check operator used on null value`

**Screenshots**:
[Attach screenshot jika ada]

**Environment**:
- Device: Android Emulator Pixel 5
- OS: Android 13
- App version: 1.0.0+7
- Flutter: 3.24.5

**Proposed Fix**:
Tambah validation di controller sebelum call use case.

**Priority**: High (crashes app)

**Assignee**: @hafis
```

### Feature Request Template
```markdown
**Title**: [Feature] Add search functionality to announcements

**Labels**: enhancement, feature:announcements, priority:medium

**Description**:
Sebagai user, saya ingin bisa search announcements berdasarkan judul atau isi, 
sehingga saya bisa cepat menemukan pengumuman yang saya cari.

**User Story**:
```
As a student,
I want to search announcements by keyword,
So that I can quickly find relevant announcements without scrolling.
```

**Acceptance Criteria**:
- [ ] Search bar tersedia di announcement page
- [ ] Search real-time (no button needed)
- [ ] Search by title and content
- [ ] Case-insensitive search
- [ ] Show "No results" state jika tidak ada match
- [ ] Clear search button (X icon)

**Design**:
[Attach mockup/wireframe jika ada]

**Technical Considerations**:
- Add search field di repository
- Filter di use case layer
- Debounce search input (300ms)
- Maintain state dengan Riverpod

**Out of Scope**:
- Advanced filters (by date, category) - will be separate feature
- Search history - future enhancement

**Priority**: Medium
**Estimated Effort**: 3-4 hours
**Assignee**: TBD
```

### Refactoring Template
```markdown
**Title**: [Refactor] Extract API client configuration to injectable service

**Labels**: refactor, tech-debt, priority:low

**Current State**:
API base URL dan timeout hard-coded di ApiClient class:
```dart
class ApiClient {
  final baseUrl = 'https://api.example.com';  // Hard-coded
  final timeout = Duration(seconds: 30);
}
```

**Problem**:
- Tidak bisa switch environment (dev/staging/prod)
- Hard to test dengan different configurations
- Violates DI principle

**Proposed Solution**:
```dart
// 1. Create config class
class ApiConfig {
  final String baseUrl;
  final Duration timeout;
  ApiConfig({required this.baseUrl, required this.timeout});
}

// 2. Inject via constructor
class ApiClient {
  final ApiConfig config;
  ApiClient(this.config);
}

// 3. Provide via Riverpod
final apiConfigProvider = Provider((ref) => ApiConfig(
  baseUrl: const String.fromEnvironment('API_BASE_URL'),
  timeout: const Duration(seconds: 30),
));
```

**Benefits**:
- Environment switching via build args
- Easier testing dengan mock config
- Follows DI principle
- Prepare untuk future multi-tenant

**Risks**:
- Breaking change untuk existing code
- Need update all API client instantiation

**Migration Path**:
1. Add ApiConfig class
2. Update ApiClient constructor (keep backward compat with default)
3. Update all providers
4. Remove default after 1 sprint
5. Announce breaking change

**Estimated Effort**: 2-3 hours
**Priority**: Low (not urgent, but good to have)
```

---

## 🎯 Issue Tracking Plan untuk Week 8

### Priority Breakdown

#### 🔴 High Priority (Must Do)
1. **#1**: Setup develop branch dan Git Flow
2. **#2**: Fix dart format inconsistencies (10 files)
3. **#3**: Setup GitHub Actions CI/CD

#### 🟡 Medium Priority (Should Do)
4. **#4**: Add widget tests untuk login page
5. **#5**: Add widget tests untuk announcement page
6. **#6**: Improve error messages (implement reflection learnings)

#### 🟢 Low Priority (Nice to Have)
7. **#7**: Add inline documentation untuk complex logic
8. **#8**: Extract API config to injectable service (refactor)
9. **#9**: Setup branch protection rules di GitHub

---

## 📝 Detailed Issues

### Issue #1: Setup develop branch dan Git Flow

**Title**: Setup develop branch dan implement Git Flow strategy

**Labels**: `enhancement`, `workflow`, `priority:high`

**Description**:
Saat ini semua commit langsung ke `main`. Perlu implement Git Flow untuk:
- Protect production branch (main)
- Enable parallel development
- Facilitate code review process

**Tasks**:
- [ ] Create `develop` branch dari `main` saat ini
- [ ] Set `develop` sebagai default branch di GitHub
- [ ] Update README dengan branching strategy
- [ ] Create first feature branch: `feature/setup-git-flow`
- [ ] Document workflow di docs/git-workflow.md

**Branch Strategy**:
```
main (protected)
  ← develop (default, integration)
      ← feature/* (daily work)
      ← fix/* (bug fixes)
```

**Success Criteria**:
- `develop` branch exists dan up-to-date dengan main
- Documentation lengkap
- Team aware of new workflow

**Estimated Effort**: 1 hour

---

### Issue #2: Fix dart format inconsistencies

**Title**: Format all code files dengan dart format

**Labels**: `style`, `tech-debt`, `priority:high`

**Description**:
Static analysis menunjukkan 10 files perlu formatting:
- lib/features/announcements/presentation/pages/announcement_page.dart
- lib/features/auth/data/datasources/token_store.dart
- lib/features/auth/data/repositories/auth_repository_impl.dart
- [+7 more files]

**Why Important**:
- Konsistensi code style
- Better diffs di PR
- Reduce merge conflicts
- Professional code appearance

**Tasks**:
- [ ] Run `dart format lib test`
- [ ] Review changes (auto-formatted)
- [ ] Commit dengan message: `style: format code dengan dart format`
- [ ] Setup pre-commit hook untuk auto-format

**Success Criteria**:
- `dart format --set-exit-if-changed lib test` exits with 0
- All files consistently formatted

**Estimated Effort**: 15 minutes

---

### Issue #3: Setup GitHub Actions CI/CD

**Title**: Implement GitHub Actions workflow untuk automated checks

**Labels**: `ci-cd`, `automation`, `priority:high`

**Description**:
Setup automated CI untuk run checks pada setiap PR:
- flutter analyze
- dart format check
- flutter test

**Benefits**:
- Catch issues before review
- Enforce code quality standards
- Reduce reviewer burden
- Professional workflow

**Tasks**:
- [ ] Create `.github/workflows/ci.yml`
- [ ] Configure Flutter action
- [ ] Add analyze step
- [ ] Add format check step
- [ ] Add test step
- [ ] Test workflow dengan dummy PR
- [ ] Setup branch protection (require CI pass)

**Success Criteria**:
- CI runs on every PR
- All checks pass on current code
- Failed checks block PR merge

**Reference**: `docs/github-actions-ci.yml`

**Estimated Effort**: 2-3 hours

---

### Issue #4: Add widget tests untuk login page

**Title**: Implement widget tests untuk login page validation

**Labels**: `test`, `feature:auth`, `priority:medium`

**Description**:
Login page tidak punya widget tests. Perlu test untuk:
- Form validation (empty fields)
- Loading states
- Error states
- Success navigation

**Test Cases**:
```dart
group('LoginPage Widget Tests', () {
  testWidgets('should show error when email empty', ...);
  testWidgets('should show error when password empty', ...);
  testWidgets('should show loading indicator when submitting', ...);
  testWidgets('should show error message on login failure', ...);
  testWidgets('should navigate to home on success', ...);
});
```

**Coverage Target**: > 80% untuk login_page.dart

**Estimated Effort**: 2-3 hours

---

### Issue #5: Add widget tests untuk announcement page

**Title**: Implement widget tests untuk announcement list

**Labels**: `test`, `feature:announcements`, `priority:medium`

**Description**:
Announcement page perlu widget tests untuk:
- Loading state
- Empty state (no announcements)
- List rendering
- Error state
- Pull to refresh

**Test Cases**:
```dart
group('AnnouncementPage Widget Tests', () {
  testWidgets('should show loading indicator initially', ...);
  testWidgets('should show empty state when no data', ...);
  testWidgets('should render announcement list', ...);
  testWidgets('should show error message on failure', ...);
  testWidgets('should refresh on pull down', ...);
});
```

**Coverage Target**: > 80% untuk announcement_page.dart

**Estimated Effort**: 2-3 hours

---

### Issue #6: Improve error messages

**Title**: Implement typed error handling dengan user-friendly messages

**Labels**: `enhancement`, `ux`, `feature:auth`, `priority:medium`

**Description**:
Based on refleksi Week 8, current error handling terlalu generic.
Perlu implement typed failures dengan specific user messages.

**Current State**:
```dart
catch (e) {
  state = AsyncValue.error('Login failed', ...);
}
```

**Desired State**:
```dart
result.fold(
  (failure) => _handleFailure(failure),  // Typed failures
  (success) => _handleSuccess(success),
);
```

**Tasks**:
- [ ] Create sealed class `AuthFailure` dengan types
- [ ] Update use cases untuk return `Either<Failure, Success>`
- [ ] Map failures ke user messages di presentation
- [ ] Add tests untuk each failure type

**Benefits**:
- Better UX (user tahu apa yang salah)
- Better debugging (typed errors)
- Better monitoring (track failure types)

**Reference**: `docs/refleksi.md` section 4

**Estimated Effort**: 3-4 hours

---

### Issue #7: Add inline documentation

**Title**: Add inline documentation untuk complex business logic

**Labels**: `docs`, `tech-debt`, `priority:low`

**Description**:
Beberapa use cases dan repository logic kompleks tanpa comments.
Perlu documentation untuk maintainability.

**Target Files**:
- `login_usecase.dart` - explain JWT flow
- `fetch_announcements_usecase.dart` - explain caching strategy
- `push_repository_impl.dart` - explain FCM handling

**Documentation Style**:
```dart
/// Authenticates user dengan email dan password.
///
/// Flow:
/// 1. Validate input (non-empty)
/// 2. Call API dengan credentials
/// 3. Store JWT token di secure storage
/// 4. Return user session
///
/// Returns:
/// - [Right(UserSession)] on success
/// - [Left(InvalidCredentialsFailure)] jika password salah
/// - [Left(NetworkFailure)] jika network error
/// - [Left(ServerFailure)] jika server error
class LoginUseCase { ... }
```

**Estimated Effort**: 1-2 hours

---

### Issue #8: Extract API config to injectable service

**Title**: Refactor: Extract API configuration to injectable service

**Labels**: `refactor`, `tech-debt`, `priority:low`

**Description**:
API base URL hard-coded. Perlu extract ke config untuk support multiple environments.

**See**: Detailed template di atas

**Estimated Effort**: 2-3 hours

---

### Issue #9: Setup branch protection rules

**Title**: Configure branch protection untuk develop dan main

**Labels**: `workflow`, `security`, `priority:low`

**Description**:
Setup branch protection di GitHub untuk enforce workflow.

**Rules untuk `main`**:
- ✅ Require PR before merging
- ✅ Require 1 approval
- ✅ Require CI checks pass
- ✅ No force push
- ✅ No deletion

**Rules untuk `develop`**:
- ✅ Require PR before merging
- ✅ Require CI checks pass
- ✅ No force push

**How to Setup**:
1. GitHub → Settings → Branches
2. Add rule
3. Branch name pattern: `main` atau `develop`
4. Enable protections

**Estimated Effort**: 30 minutes

---

## 📊 Issue Board (Kanban)

### Backlog
- #7: Add inline documentation
- #8: Extract API config
- #9: Setup branch protection

### To Do (Sprint Week 8)
- #1: Setup develop branch ⚡ HIGH
- #2: Fix dart format ⚡ HIGH
- #3: Setup CI/CD ⚡ HIGH

### In Progress
- (Will be updated as work starts)

### In Review
- (Will be updated when PRs created)

### Done ✅
- (Will be updated as issues closed)

---

## 🏷️ Label System

### Type Labels
- `bug` - Something tidak berfungsi
- `enhancement` - New feature atau improvement
- `refactor` - Code improvement tanpa behavior change
- `test` - Test-related issues
- `docs` - Documentation updates
- `ci-cd` - CI/CD dan automation

### Priority Labels
- `priority:high` - Must do this sprint (🔴 Red)
- `priority:medium` - Should do this sprint (🟡 Yellow)
- `priority:low` - Nice to have (🟢 Green)

### Feature Labels
- `feature:auth` - Authentication related
- `feature:announcements` - Announcements related
- `feature:messaging` - FCM/Push related

### Status Labels
- `blocked` - Tidak bisa lanjut (dependency)
- `help-wanted` - Need assistance
- `good-first-issue` - Good untuk new contributor

---

## 🔗 Linking Issues to PRs

### Format
```markdown
Closes #1
Fixes #2
Resolves #3
```

### Example PR Description
```markdown
## Description
Setup develop branch dan implement Git Flow strategy.

## Changes
- Created develop branch dari main
- Updated README dengan branching strategy
- Added git-workflow.md documentation

## How to Test
```bash
git fetch origin
git checkout develop
git branch -a  # verify develop exists
```

## Checklist
- [x] develop branch created
- [x] Documentation updated
- [x] Team notified

Closes #1
```

---

## 📈 Issue Metrics

### Sprint Week 8 Goals
- **Total Issues**: 9
- **High Priority**: 3 (33%)
- **Medium Priority**: 3 (33%)
- **Low Priority**: 3 (33%)

### Target Completion
- **High**: 100% (3/3) ✅
- **Medium**: 66% (2/3) ✅
- **Low**: 33% (1/3) ✅

### Time Estimates
- **High Priority**: ~4 hours
- **Medium Priority**: ~8 hours
- **Low Priority**: ~4 hours
- **Total**: ~16 hours (2 days focused work)

---

**Document Status**: ✅ Complete  
**Last Updated**: 19 Oktober 2026  
**Next Review**: After first sprint completed
