# Catatan CI - Week 13: CI/CD dan Otomatisasi

Lanjutan aplikasi **Catatan Test** (Week 12). Minggu ini tidak menambah fitur. Semua pemeriksaan yang sebelumnya dijalankan manual (format, analisis, test, build Android) kini dijalankan otomatis oleh **GitHub Actions** di setiap pull request dan push ke `main`. Hasil build disimpan sebagai artefak yang bisa diunduh.

- Workflow: [`.github/workflows/flutter-ci.yml`](../.github/workflows/flutter-ci.yml) (file workflow wajib ada di root repo, bukan di folder minggu)
- Padanan lokal: [`tool/ci_local.sh`](tool/ci_local.sh)
- Refleksi: [`docs/refleksi.md`](docs/refleksi.md)

---

## 1. Alur Pipeline

```
PR ke main / push ke main / tag v* / manual (workflow_dispatch)
  └─ runner ubuntu-latest
       1. checkout
       2. Java 17 (Temurin) + Flutter 3.32.1 (dikunci, sama dengan lokal)
       3. flutter pub get
       4. dart format --output=none --set-exit-if-changed .
       5. flutter analyze --fatal-infos
       6. flutter test --coverage
       7. flutter build apk --release
       8. flutter build appbundle --release
       9. sha256sum APK + AAB
      10. upload artefak  android-builds-<sha commit>  (APK, AAB, checksums.txt)
                          coverage-<sha commit>        (lcov.info)
```

Setiap step berhenti di kegagalan pertama. Jadi **APK/AAB tidak dibangun bila format, analisis, atau test gagal**.

| Keputusan | Alasan |
|---|---|
| `permissions: contents: read` | Job hanya membaca kode. Tidak ada izin tulis ke repo, issue, atau release. |
| Tidak memakai GitHub Secrets | Pipeline ini belum menandatangani rilis produksi, jadi tidak ada secret yang perlu disimpan. PR dari fork juga aman karena tidak ada secret yang bisa bocor. |
| Action di-pin ke **commit SHA** (`actions/checkout@11d5960…  # v4`) | Tag seperti `v4` bisa dipindah oleh pemilik action. SHA tidak bisa diubah, sehingga kode yang jalan di runner tetap sama. |
| Flutter `3.32.1`, bukan "stable terbaru" | Hasil CI sama dengan hasil lokal. Upgrade dilakukan sengaja lewat PR, bukan diam-diam. |
| `paths:` hanya folder Week 13 + file workflow | Repo ini berisi 16 project mingguan. Perubahan di minggu lain tidak memicu build Android Week 13. |
| `concurrency` + `cancel-in-progress` | Push baru ke PR yang sama membatalkan run lama, sehingga waktu runner tidak terbuang. |
| Nama artefak memuat SHA commit + `checksums.txt` | File yang diunduh bisa ditelusuri ke commit pembuatnya, dan keasliannya bisa dicek. |
| `retention-days: 7` | Artefak hanya untuk ditinjau, bukan arsip rilis. Kuota penyimpanan juga tetap kecil. |
| `timeout-minutes: 30` | Job yang macet tidak menghabiskan kuota 6 jam bawaan. |

Workflow lama [`ci.yml`](../.github/workflows/ci.yml) (analyze + test untuk Week 7–12) tetap ada, dan kini juga diberi `permissions: contents: read`.

---

## 2. Hasil Pemeriksaan

### Lokal (`bash tool/ci_local.sh`), Windows 11, Flutter 3.32.1 / Dart 3.8.1

| Step | Hasil |
|---|---|
| `dart format --output=none --set-exit-if-changed .` | ✅ 47 file, 0 berubah |
| `flutter analyze --fatal-infos` | ✅ No issues found |
| `flutter test --coverage` | ✅ +77, All tests passed (cakupan 78,9%) |
| `flutter build apk --release` | ✅ `app-release.apk` 48,5 MB (± 4 menit, build pertama) |
| `flutter build appbundle --release` | ✅ `app-release.aab` 40,9 MB (± 26 detik, cache Gradle sudah hangat) |

Isi APK diperiksa dengan `aapt` dan `apksigner`:

```
package: name='com.example.week13_ci_notes' versionCode='2' versionName='1.1.0'
Signer #1 certificate DN: C=US, O=Android, CN=Android Debug   <- lihat Risiko Keamanan
```

### Bukti kegagalan test menghentikan pipeline

Batas judul sengaja dirusak (`>` diganti `>=` di `validate_note_title.dart`), lalu pipeline lokal dijalankan:

```
==> dart format
==> flutter analyze
==> flutter test --coverage
... tepat 80 karakter diterima [E]
... spasi tambahan di luar batas tidak ikut dihitung [E]
... emoji dihitung 1 karakter, bukan 2 unit UTF-16 [E]
00:23 +74 -3: Some tests failed.
pipeline exit=1        <- step build APK/AAB tidak dijalankan
```

Setelah kode dikembalikan, pipeline kembali lulus (+77).

### GitHub Actions

| Run | Commit | Hasil |
|---|---|---|
| PR `feat/week13-ci-cd` | _diisi setelah run_ | _menunggu_ |
| PR uji gagal (test sengaja dirusak) | _diisi setelah run_ | _menunggu_ |

> Saat dokumen ini ditulis, job GitHub Actions di akun ini tidak bisa dimulai: *"The job was not started because your account is locked due to a billing issue."* Akun harus dibuka dulu di **Settings → Billing and plans**. Repo publik tidak dikenai biaya menit Actions, tetapi akun yang terkunci tetap memblokir semua job. Setelah itu tabel di atas dan `screenshots/` diisi dengan bukti run dan artefak.

---

## 3. Versioning

| | Versi | Keterangan |
|---|---|---|
| Week 5–12 | `1.0.0+1` | Belum pernah dinaikkan. |
| **Week 13 (sekarang)** | **`1.1.0+2`** | **Minor**: fitur kompatibel baru sejak `1.0.0` (form tambah catatan dengan validasi di Week 12, chat AI di Week 10). Build number naik karena ada artefak baru. |
| Berikutnya (rencana) | `1.1.1+3` | **Patch**: pesan error memuat yang ramah pengguna (masih tampil `Error: Exception: ...`, temuan Week 12). |
| Setelah itu (rencana) | `1.2.0+4` | **Minor**: rilis bertanda tangan sungguhan (Week 14 Deployment). |

- Format `MAJOR.MINOR.PATCH+BUILD`. `BUILD` menjadi `versionCode` Android dan harus naik untuk setiap unggahan ke Play Store.
- Tag `v1.1.0` dibuat **setelah** PR ini di-merge dan run di `main` hijau, supaya tag menunjuk commit yang sudah lolos pemeriksaan. Push tag `v*` juga menjalankan pipeline.

  ```bash
  git checkout main && git pull
  git tag -a v1.1.0 -m "Catatan CI 1.1.0+2"
  git push origin v1.1.0
  ```

---

## 4. Risiko Keamanan yang Masih Perlu Ditangani

1. **APK/AAB "release" masih ditandatangani dengan debug key.** `android/app/build.gradle.kts` memakai `signingConfigs.getByName("debug")`. Di runner, debug keystore dibuat baru di setiap run, sehingga APK dari dua run berbeda tidak bisa saling meng-update di perangkat. Play Store juga menolak AAB ini. Untuk rilis: buat upload keystore, simpan sebagai GitHub Secret (base64 + password), lalu pakai **hanya** di workflow rilis yang dipicu tag atau `workflow_dispatch` dengan *environment protection* (persetujuan manual). Jangan pernah memakainya di workflow `pull_request`.
2. **Artefak di repo publik bisa diunduh siapa pun yang login ke GitHub.** Saat ini aman karena tidak ada secret di dalam APK. Tapi jangan pernah mengompilasi API key ke aplikasi lewat `--dart-define`: nilainya bisa diekstrak dari APK. API key Groq (Week 10) tetap dimasukkan pengguna dan disimpan di `flutter_secure_storage`, bukan di build.
3. **Supply chain action pihak ketiga.** SHA sudah di-pin, tapi tidak ada yang memperbaruinya otomatis. Perlu Dependabot (`package-ecosystem: github-actions`) atau pengecekan berkala, termasuk dependensi pub (`flutter pub outdated`: 54 paket punya versi lebih baru).
4. **`applicationId` masih `com.example.*`.** Play Store menolak prefiks ini. Harus diganti sebelum rilis.
5. **Branch protection belum aktif.** Tanpa aturan *"Require status checks to pass"*, PR merah tetap bisa di-merge. Aktifkan di Settings → Branches setelah Actions berjalan.
6. **Integration test tidak dijalankan di CI.** Butuh emulator (lambat dan rawan gagal di runner Linux). Saat ini hanya dijalankan manual sebelum rilis.

---

## 🏃 Cara Menjalankan

```bash
cd 13-week-13-ci-cd-automation
bash tool/ci_local.sh               # semua step seperti CI, termasuk build
SKIP_BUILD=1 bash tool/ci_local.sh  # tanpa build (± 1 menit)
flutter test integration_test/app_test.dart -d <device_id>   # manual, butuh emulator
```

Di GitHub: tab **Actions → Flutter CI → Run workflow** (manual), atau buka PR ke `main`. Artefak ada di bagian **Artifacts** di bawah ringkasan run.

---

## 👤 Informasi Mahasiswa

- **Nama**: Hafis
- **NIM**: 254107023005
- **Mata Kuliah**: Pemrograman Mobile (Semester 5)
- **Jurusan**: Teknologi Informasi - Politeknik Negeri Malang
