# Refleksi - Week 13: CI/CD dan Otomatisasi

**Tanggal**: 20 November 2026

---

### 1. Masalah apa yang ditemukan otomatis sebelum perubahan di-merge?

Saat pipeline disusun dan diuji di lokal, pemeriksaan otomatis menunjukkan:

- **Test yang gagal benar-benar menghentikan pipeline.** Batas judul sengaja dirusak (`>` menjadi `>=`). Tiga test langsung gagal, dan APK/AAB tidak dibangun. Tanpa CI, kesalahan off-by-one seperti ini mudah lolos karena aplikasinya tetap bisa dijalankan.
- **Versi Flutter di CI tidak sama dengan lokal.** Sebelumnya CI memakai Flutter 3.24.5, yang tidak cocok dengan `sdk: ^3.8.1`. Karena itu versi sekarang dikunci ke 3.32.1.
- **APK "release" ternyata ditandatangani debug key.** Hal ini baru terlihat saat isi artefak diperiksa dengan `apksigner`, bukan dari keberhasilan build.
- Masalah format kode Week 7 juga pertama kali tertangkap oleh step `dart format` di CI.

### 2. Informasi apa yang Anda butuhkan untuk menyelidiki build yang gagal?

- **Step mana yang gagal** dan log lengkapnya (nama test yang `[E]`, pesan analyzer, atau error Gradle).
- **Versi tool**: Flutter, Dart, Java. Karena itu ada step "Versi tool" di awal workflow.
- **Commit SHA dan versi `pubspec.yaml`** yang dibangun. Keduanya tercetak di log dan ikut di nama artefak.
- **Bisa direproduksi di lokal atau tidak.** `tool/ci_local.sh` menjalankan perintah yang sama, jadi bisa dibedakan apakah masalahnya di kode atau di lingkungan runner.
- **Status akun/runner.** Kegagalan "job was not started" (akun terkunci billing) bukan masalah kode sama sekali, dan baru kelihatan dari anotasi run, bukan dari log step.

### 3. Bagian mana yang masih perlu persetujuan atau pemeriksaan manual sebelum rilis?

- **Signing rilis**: membuat dan menyimpan upload keystore, lalu menyetujui workflow rilis (environment protection).
- **Integration test di perangkat/emulator.** Belum dijalankan di CI.
- **Uji manual di HP sungguhan**: izin aplikasi, tampilan, mode offline, dan fitur chat AI dengan API key asli.
- **Keputusan versi dan pembuatan tag** `v1.1.0` setelah `main` hijau.
- **Review kode PR**, termasuk memastikan tidak ada secret atau API key yang ikut ter-commit.
- **Pengaturan branch protection** agar PR merah tidak bisa di-merge.
