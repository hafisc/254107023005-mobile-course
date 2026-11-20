#!/usr/bin/env bash
# Menjalankan langkah yang sama dengan .github/workflows/flutter-ci.yml di
# mesin lokal. Berhenti di kegagalan pertama (set -e), sama seperti runner:
# bila test gagal, APK/AAB tidak dibangun.
#
#   bash tool/ci_local.sh            # semua langkah
#   SKIP_BUILD=1 bash tool/ci_local.sh   # tanpa build (lebih cepat)
set -euo pipefail
cd "$(dirname "$0")/.."

step() { printf '\n==> %s\n' "$*"; }

step "Versi"
flutter --version | head -1
grep '^version:' pubspec.yaml
echo "Commit: $(git rev-parse --short HEAD)$(git diff --quiet || echo ' (+ perubahan belum di-commit)')"

step "flutter pub get";            flutter pub get
step "dart format";                dart format --output=none --set-exit-if-changed .
step "flutter analyze";            flutter analyze --fatal-infos
step "flutter test --coverage";    flutter test --coverage

if [[ "${SKIP_BUILD:-0}" == "1" ]]; then
  step "Build dilewati (SKIP_BUILD=1)"
  exit 0
fi

step "flutter build apk";          flutter build apk --release
step "flutter build appbundle";    flutter build appbundle --release

step "Artefak"
cd build/app/outputs
sha256sum flutter-apk/app-release.apk bundle/release/app-release.aab | tee checksums.txt
ls -la flutter-apk/app-release.apk bundle/release/app-release.aab
