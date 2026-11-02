# Refleksi - Week 8: Mid Project Review & Code Review

**Tanggal**: 2 November 2026

---

## 1. Apa beda LGTM buta dengan approve yang bertanggung jawab? Apa risikonya bagi tim?

**LGTM Buta** ("Looks Good To Me") adalah approval yang diberikan tanpa benar-benar memeriksa kode — reviewer hanya membaca sekilas atau bahkan langsung approve tanpa membuka PR sama sekali.

**Approve yang Bertanggung Jawab** berarti reviewer:
- Meng-*checkout* branch dan menjalankan `flutter run` sendiri
- Menjalankan `flutter test` dan `flutter analyze`
- Membaca kode secara kritis dengan checklist (kebenaran, arsitektur, testing)
- Memberikan komentar yang actionable dengan bukti

**Risiko LGTM Buta bagi Tim**:
1. **Bug lolos ke production** — edge case atau null safety issue yang terlewat reviewer akan ditemukan oleh pengguna.
2. **Technical debt menumpuk** — kode bermasalah yang di-approve menjadi "warisan" yang sulit diubah karena "sudah di-review".
3. **Kepercayaan reviewer jatuh** — jika bug lolos berkali-kali, tim kehilangan kepercayaan pada proses review.
4. **Dependency rule rusak perlahan** — satu import `Dio` yang lolos di domain layer akan membuat orang lain merasa itu "boleh".
5. **Demoralissasi author** — author yang menulis kode dengan susah payah merasa review tidak dihargai.

**Kesimpulan**: LGTM buta bukan menghemat waktu — ia hanya memindahkan masalah dari review ke production.

---

## 2. Kapan komentar wajib berstatus `Request Changes`, dan kapan cukup saran?

### Wajib `Request Changes` (blocker):
- **Melanggar dependency rule**: import `Dio`/`Flutter` di domain layer — ini merusak arsitektur dasar.
- **Bug nyata**: null crash yang bisa direproduksi, data hilang tanpa error handling, token tidak pernah di-refresh.
- **Test hilang untuk perubahan behavior**: PR mengubah logika bisnis tapi tidak ada test yang diperbarui.
- **Security issue**: kredensial ter-hardcode, token tidak pernah di-clear saat logout.

### Cukup Saran (non-blocker):
- **Style**: penamaan variabel kurang deskriptif tapi tidak ambigu.
- **Optimasi opsional**: bisa memakai `const` di sini tapi tidak blocking.
- **Refactor kosmetik**: method bisa dipecah tapi saat ini masih mudah dibaca.
- **Test tambahan yang nice-to-have**: kasus edge yang sudah tertutup oleh behavior test lain.

**Aturan jempol**: jika dibiarkan tidak diperbaiki, apakah akan menyebabkan bug, security issue, atau arsitektur rusak? Jika ya → `Request Changes`. Jika tidak → Saran/komentar biasa.

---

## 3. Bagian mana dari review AI yang saya tolak atau sederhanakan, dan mengapa?

### Ditolak: Saran menghapus `LoginUseCase` (Temuan #4)

AI menyarankan menghapus `LoginUseCase` karena "terlalu tipis, hanya meneruskan ke repository". Saya menolak ini karena:

1. **Use case tipis tetap valid** dalam Clean Architecture — ia adalah titik ekstensi. Jika validasi tambahan (misal: cek email di-blocklist) perlu ditambahkan nanti, cukup tambahkan di sini tanpa menyentuh presentation atau data.
2. **Testability terjaga** — `LoginUseCase` bisa ditest dengan `FakeAuthRepository` tanpa memerlukan Flutter test environment sama sekali. Ini terbukti di `test/login_usecase_test.dart`.
3. **AI tidak memahami intent arsitektur** — menghapus use case sama dengan menghapus lapisan Domain yang bermakna, yang melanggar semangat codelab minggu 7.

### Ditolak: Saran tambah validasi UI dengan Form (Temuan #3)

AI menyarankan mengganti `TextField` dengan `TextFormField` + `Form` + `validator`. Saya menolak karena:
1. Validasi sudah ada di domain layer (`password.length < 6`, `!email.contains('@')`).
2. Menambahkan validasi di UI akan menduplikasi logika bisnis — melanggar Single Responsibility.
3. Ini saran UX, bukan kebenaran arsitektur.

---

## 4. Satu hal konkret yang saya perbaiki setelah review AI — apa dampaknya?

### Perbaikan: `FakeAuthRepository.refresh()` menggunakan `Failure` bukan `UnimplementedError`

**Sebelum**:
```dart
@override
Future<({String? token, Failure? failure})> refresh(String refreshToken) {
  throw UnimplementedError(); // crash jika terpanggil
}
```

**Sesudah**:
```dart
@override
Future<({String? token, Failure? failure})> refresh(String refreshToken) async {
  return (token: null, failure: const NetworkFailure('refresh not implemented in fake'));
}
```

**Dampak**:
1. **Test lebih robust** — jika use case lain yang ditest secara tidak sengaja memanggil `refresh()`, test tidak crash dengan stack trace yang membingungkan, melainkan gagal dengan pesan error yang jelas.
2. **Konsisten dengan Liskov Substitution** — fake repository seharusnya berperilaku seperti aslinya (mengembalikan `Failure`), bukan crash.
3. **Habit yang baik** — saat `FakeRepository` tumbuh lebih banyak method, pola "selalu return Failure bukan throw" membuat test suite lebih stabil.

Perubahan kecil ini mengajarkan saya bahwa test yang robust adalah investasi — satu crash `UnimplementedError` yang tidak terduga bisa menghabiskan waktu debugging lebih lama daripada menulis perbaikan 3 barisnya.
