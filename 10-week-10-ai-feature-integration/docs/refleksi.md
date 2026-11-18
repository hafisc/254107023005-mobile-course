# Refleksi - Week 10: Integrasi Fitur AI

**Tanggal**: 16 November 2026

---

### 1. Fitur AI mana yang Anda integrasikan dan mengapa?

Chat Asisten AI dengan Groq (model `openai/gpt-oss-20b`), ditambahkan ke aplikasi Catatan Offline dari Minggu 9. Saya memilih chat karena paling cocok dengan aplikasi catatan: pengguna bisa bertanya tentang catatannya sendiri ("catatan apa saja yang saya punya?") tanpa perlu mencari manual. Chat juga cukup untuk mempraktikkan streaming response, prompt design, dan error handling, tanpa izin tambahan seperti kamera atau mikrofon yang dibutuhkan OCR dan Speech-to-Text.

### 2. Bagaimana Anda melindungi privasi pengguna saat menggunakan AI API?

- **Redaksi otomatis**: sebelum dikirim, `redactPii()` mengganti email, NIK 16 digit, dan nomor HP Indonesia menjadi `[EMAIL]`, `[NIK]`, `[TELEPON]`. Ini diuji di `redact_pii_test.dart`.
- **Konteks minimal**: yang dikirim hanya maksimal 10 judul catatan, bukan isi catatan.
- **API key aman**: key disimpan di `flutter_secure_storage` (Android Keystore), tidak ada di kode, dan dikirim lewat header `Authorization`, bukan URL.
- **Transparansi**: banner di halaman chat memberi tahu pengguna bahwa data pribadi disamarkan.

### 3. Fallback apa yang Anda sediakan jika layanan AI error?

- Setiap jenis error punya pesan ramah dan aksinya sendiri: key belum diatur atau ditolak -> tombol "Buka Pengaturan"; offline, sibuk (429), atau server error -> tombol "Coba lagi".
- **Mode offline**: saat AI gagal, aplikasi mencari catatan lokal yang memuat kata dari pertanyaan (memakai ulang `filterNotes` Minggu 9), jadi pengguna tetap mendapat sesuatu yang berguna.
- **Cache lokal**: pertanyaan yang pernah dijawab diambil dari cache tanpa memanggil API.
- **Kuota**: maksimal 20 pertanyaan per hari supaya biaya tidak melonjak.

### 4. Satu hal yang Anda pelajari tentang UX fitur AI di mobile?

Streaming membuat jawaban terasa jauh lebih cepat walaupun total waktunya sama, karena pengguna langsung melihat teks muncul alih-alih menunggu layar loading. Di sisi lain, fitur AI harus dirancang dengan asumsi bahwa ia *akan* gagal (tanpa sinyal, key salah, kuota habis). Pesan error yang jelas dan aksi berikutnya yang konkret sama pentingnya dengan jawaban AI itu sendiri.
