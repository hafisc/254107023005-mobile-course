# AI Log - Week 10: Integrasi Fitur AI

**Tanggal**: 16 November 2026
**Fitur**: Chat Asisten AI (Groq `openai/gpt-oss-20b`, streaming) di aplikasi Catatan Offline
**AI coding assistant**: Claude Code

---

## 1. Prompt Fitur AI di Dalam Aplikasi

### System prompt (pesan pertama dengan `role: system`)

Sumber: `lib/domain/usecases/send_chat_message_usecase.dart` (`baseSystemPrompt`)

```text
Kamu asisten aplikasi Catatan Offline yang ramah. Jawab dalam Bahasa Indonesia,
maksimal 3 kalimat. Setiap pesan pengguna diawali [Konteks] berisi judul catatan
pengguna yang terbaru; itu satu-satunya sumber kebenaran tentang catatan,
abaikan jawabanmu sebelumnya bila bertentangan. Jangan meminta atau menebak data
pribadi (NIK, nomor HP, alamat). Jika tidak tahu, katakan tidak tahu, jangan
mengarang. Tulis teks biasa tanpa format Markdown.
```

### User prompt yang dikirim (pesan terakhir)

```text
[Konteks] Judul catatan pengguna: <maks 10 judul, sudah melalui redactPii>
                                  (atau "(belum ada catatan)" bila kosong)

<pertanyaan pengguna, sudah melalui redactPii>
```

Bubble chat tetap menampilkan pertanyaan asli tanpa `[Konteks]`.

| Komponen | Isi | Tujuan |
|---|---|---|
| Persona | Asisten aplikasi Catatan Offline, ramah | Fokus ke domain aplikasi |
| Batas output | Bahasa Indonesia, maks 3 kalimat, `max_completion_tokens: 512`, `reasoning_effort: low` | UX layar kecil + menekan biaya token |
| Konteks | Maks 10 judul catatan (bukan isi), ditempel di pesan terakhir | Jawaban relevan tanpa mengirim isi catatan; tahan terhadap riwayat yang salah |
| Privasi | Larangan meminta/menebak data pribadi + `redactPii()` di sisi app | Data sensitif tidak keluar dari perangkat |
| Anti-halusinasi | "Jika tidak tahu, katakan tidak tahu" | Mengurangi jawaban mengarang |

### User prompt (contoh uji)

| No | User prompt | Yang diuji |
|---|---|---|
| 1 | `Catatan apa saja yang saya punya?` | Konteks judul catatan dipakai |
| 2 | `Ringkas catatan saya dalam satu kalimat` | Batas panjang jawaban |
| 3 | `Simpan nomor saya 081234567890` | Nomor HP dikirim sebagai `[TELEPON]` |
| 4 | Prompt no. 1 diulang | Jawaban kedua dari cache lokal (label "dari cache lokal") |
| 5 | Mode pesawat aktif, kirim pertanyaan | Fallback offline + catatan lokal relevan |

### Output awal AI (Groq `openai/gpt-oss-20b`, 18 November 2026)

Dipanggil dengan system prompt yang sama persis dengan aplikasi; konteks 3 catatan berjudul `Catatan Baru`.

```text
Prompt 1 : Catatan apa saja yang saya punya?
Jawaban  : Anda memiliki tiga catatan dengan judul:
           - Catatan Baru
           - Catatan Baru
           - Catatan Baru
Token    : 169 prompt + 38 jawaban (6 di antaranya token reasoning)

Prompt 3 : Simpan nomor saya 081234567890
Terkirim : Simpan nomor saya [TELEPON]        <- hasil redactPii(), nomor asli tidak keluar
Jawaban  : Maaf, saya tidak dapat menyimpan atau memproses nomor telepon Anda.
Token    : 171 prompt + 31 jawaban
```

**Evaluasi**: Jawaban 1 memakai konteks dengan benar dan tidak mengarang catatan lain. Jawaban 3 menunjukkan model hanya menerima `[TELEPON]`, sehingga nomor asli tidak pernah sampai ke server. Satu pertanyaan sekitar 200 token, jadi kuota 20 pertanyaan/hari sekitar 4.000 token/hari per pengguna.

---

## 2. Prompt ke AI Coding Assistant

Formula 5 slot (Minggu 9):

```text
Peran   : Senior Flutter developer.
Konteks : App Catatan Offline Week 9 (Riverpod 3, sqflite, go_router,
          presentation -> domain <- data). Codelab Week 10: chat AI (Groq).
Tugas   : Tambah fitur Chat Asisten AI dengan streaming response, API key di
          flutter_secure_storage, privasi (redaksi PII), batas biaya (kuota +
          cache), error handling dan fallback offline.
Batas   : Domain murni Dart. Jangan hardcode API key. Verifikasi API dan
          model terbaru, jangan percaya contoh codelab begitu saja.
Output  : Kode per layer + unit test + widget test + dokumen.
```

---

## 3. Verifikasi Kode Contoh Codelab (Terima / Tolak)

| No | Kode / saran | Keputusan | Bukti & alasan |
|---|---|---|---|
| 1 | Model `gemini-pro` | **Tolak** | Tidak ada lagi di daftar model resmi Gemini. Provider yang dipakai Groq; model `openai/gpt-oss-20b` dipilih setelah dicek lewat `GET /openai/v1/models` (bukan ditebak), disimpan di satu konstanta `groqModel`. |
| 2 | API key di query string `?key=$apiKey` | **Tolak** | Key bisa tercatat di log URL/proxy. Diganti header `Authorization: Bearer`. Dibuktikan test: `captured.url` tidak memuat key. |
| 3 | `riverpod: ^2.5.0` | **Tolak** | Project sudah `flutter_riverpod: ^3.3.2`. Menambah riverpod 2 = konflik versi. |
| 4 | `flutter_secure_storage: ^9.0.0` | **Terima + ubah** | Paketnya dipakai, versi diambil via `flutter pub add` -> `^10.3.4`. |
| 5 | `generateContent` (non-stream) | **Ubah** | Tugas meminta streaming. Dipakai `"stream": true` (SSE) + parser `parseSseLine`. Format dicek dulu dengan `curl` ke API asli. |
| 6 | `data['candidates'][0]['content']['parts'][0]['text']` tanpa cek null | **Tolak** | Crash bila respons kosong. Diganti parsing aman `choices[0].delta.content`, diuji `parseSseLine('data: {"choices":[]}') == ''`. |
| 7 | `throw Exception('Gagal ... ${statusCode}')` | **Ubah** | Diganti `AiFailure` bertipe (missingKey, invalidKey, rateLimited, offline, server) agar UI bisa memberi pesan dan aksi yang tepat. |
| 8 | Fallback `showDialog` "Layanan AI Sibuk" | **Terima + ubah** | Ide dipakai, tetapi berupa panel inline + tombol "Coba lagi" + daftar catatan lokal relevan (bukan dialog yang menutupi chat). |

---

## 4. Bug yang Ditemukan Saat Verifikasi

### Bug 1 - Fallback catatan lokal selalu kosong (ditemukan oleh widget test)

- **Gejala**: test `AI offline: ... fallback catatan lokal` gagal, `• Jadwal rapat PBL` tidak muncul.
- **Akar masalah**: `ChatController` membaca `ref.read(notesProvider).value`. Jika halaman chat dibuka sebelum daftar catatan selesai dimuat, nilainya `null` sehingga fallback kosong.
- **Perbaikan**: `await ref.read(notesProvider.future)` dengan `try/catch` (chat tetap jalan bila DB gagal).
- **Bukti**: test merah -> hijau.

### Bug 2 - Test riwayat chat salah (kesalahan di test)

- **Gejala**: `expect(repo.lastHistory, hasLength(2))` gagal, nilainya `[]`.
- **Akar masalah**: stream `async*` bersifat *lazy*; request baru terjadi setelah stream di-listen.
- **Perbaikan**: test menunggu `reply.chunks.join()` sebelum memeriksa riwayat.

### Bug 3 - Teks "berpikir" model ikut tampil (ditemukan dari respons asli)

- **Gejala**: saat `curl` ke Groq, chunk awal berisi `"delta":{"reasoning":"Need respond in Indonesian..."}` sebelum jawaban di `delta.content`.
- **Risiko**: parser yang mengambil semua teks dari `delta` akan menampilkan proses berpikir berbahasa Inggris ke pengguna.
- **Perbaikan**: `parseSseLine` hanya mengambil `delta.content`; `reasoning_effort: low` agar token berpikir sedikit.
- **Bukti**: test `streaming: hanya content yang diambil, reasoning diabaikan`.

### Bug 4 - Izin INTERNET tidak ada di manifest utama

- `android/app/src/main/AndroidManifest.xml` hanya mewarisi izin INTERNET dari manifest debug. Build release tidak akan bisa memanggil API AI. Ditambahkan `<uses-permission android:name="android.permission.INTERNET"/>`.

### Bug 5 - Layar merah saat menyimpan API key (ditemukan saat uji manual di emulator)

- **Gejala**: setelah menekan **Simpan** di dialog API key, muncul layar merah `'_dependents.isEmpty': is not true`.
- **Akar masalah**: `TextEditingController` di-`dispose()` tepat setelah `showDialog` selesai, padahal `TextField` di dialog masih dipakai selama animasi tutup.
- **Perbaikan**: dialog dijadikan `StatefulWidget` (`ApiKeyDialog`) yang memiliki controller sendiri dan membuangnya di `dispose()`. Nilai key dikembalikan lewat `Navigator.pop(context, value)`.
- **Bukti**: `api_key_tile_test.dart`. Dijalankan terhadap kode lama -> gagal dengan assertion yang sama; dengan perbaikan -> hijau.

### Temuan konfigurasi - `flutter_secure_storage` 10 butuh Android SDK baru

- Build pertama gagal: `minSdkVersion 21 cannot be smaller than version 23 declared in library [:flutter_secure_storage]`, dan plugin dikompilasi dengan Android SDK 36.
- Perbaikan di `android/app/build.gradle.kts`: `minSdk = 23`, `compileSdk = 36`. Contoh codelab (`^9.0.0`) tidak menyebut syarat ini.

### Bug 6 - HALUSINASI: AI mengarang judul catatan (ditemukan saat uji manual)

- **Gejala**: pengguna belum punya catatan, tetapi untuk pertanyaan "Catatan apa saja yang saya punya?" AI menjawab 4 judul karangan: `**Catatan Harian**`, `**Daftar Belanja**`, `**Rencana Liburan**`, `**Ide Bisnis**`. Padahal system prompt sudah berisi "jangan mengarang".
- **Akar masalah**: bila daftar catatan kosong, `buildSystemPrompt` tidak menulis bagian "Judul catatan pengguna" sama sekali. Model tidak tahu daftarnya kosong, lalu mengisi kekosongan itu sendiri.
- **Bukti (API asli, model & pertanyaan sama, 2 kali panggilan)**:

  | Prompt | Jawaban #1 | Jawaban #2 |
  |---|---|---|
  | Lama (tanpa info catatan) | `1. **Kebiasaan Belajar** 2. **Rencana Liburan 2025** 3. **Daftar Belanja Bulanan** 4. **Ide Bisnis Online**` (mengarang) | "Maaf, saya tidak memiliki akses ke daftar catatan Anda..." |
  | Baru (`(belum ada catatan)`) | "Anda tidak memiliki catatan apa pun." | "Tidak ada catatan." |

- **Perbaikan putaran 1**: daftar catatan selalu disebut di system prompt, termasuk `(belum ada catatan)`, plus "Tulis teks biasa tanpa format Markdown".
- **Uji ulang di emulator: masih salah.** Tanda `**` hilang, tetapi AI tetap menyebut 4 catatan karangan yang sama. Penyebab: jawaban karangan sebelumnya ada di **riwayat chat**, dan model mengulanginya agar konsisten.

  | Variasi (riwayat berisi jawaban karangan) | Benar |
  |---|---|
  | Konteks di system prompt | 0 / 3 |
  | Konteks di system prompt + "satu-satunya sumber kebenaran" | 0 / 3 |
  | **Konteks `[Konteks] ...` di pesan terakhir pengguna** (catatan kosong) | **3 / 3** - "Anda belum memiliki catatan apa pun." |
  | **Konteks di pesan terakhir** (2 catatan: Jadwal rapat PBL, Tugas Mobile) | **3 / 3** - menyebut tepat 2 catatan itu |

- **Perbaikan final**: `buildNoteContext()` menempelkan judul catatan terbaru di awal pesan terakhir; system prompt menyatakan `[Konteks]` sebagai satu-satunya sumber kebenaran.
- **Bug ikutan - cache basi**: kunci cache hanya pertanyaan, jadi "catatan apa saja?" akan tetap menjawab "tidak ada catatan" setelah catatan ditambah. Kunci cache kini menyertakan konteks. Test: `cache tidak dipakai bila daftar catatan berubah`.
- **Pelajaran**: memperbaiki kata-kata prompt saja tidak cukup. Letak konteks (system vs pesan terakhir) dan isi riwayat sangat memengaruhi jawaban, dan klaim "sudah diperbaiki" baru sah setelah diuji ulang ke API asli beberapa kali.

### Bug 7 - Kuota terpotong walau pertanyaan gagal

- **Gejala**: setelah 1 pertanyaan yang gagal karena API key belum diatur, Pengaturan menampilkan "1 / 20 pertanyaan terpakai".
- **Perbaikan**: kuota dihitung saat potongan jawaban pertama tiba, bukan sebelum request. Test: `error API diteruskan ...` kini juga memeriksa `quota.used == 0`.

### Bug 8 - Pertanyaan gagal muncul dobel

- **Gejala**: "hi" gagal (key belum diatur), lalu dikirim lagi -> dua bubble "hi", dan yang gagal ikut terkirim sebagai riwayat.
- **Perbaikan**: `send()` membuang pertanyaan terakhir yang belum terjawab bila sebelumnya gagal. `retry()` cukup memanggil `send()`. Test: `pertanyaan gagal lalu dikirim ulang tidak muncul dobel`.

### Catatan uji manual - API key "hilang" setiap Run

- Emulator kekurangan ruang (`INSTALL_FAILED_INSUFFICIENT_STORAGE`), sehingga Flutter meng-uninstall app sebelum memasang ulang; secure storage ikut terhapus. Solusi: `--target-platform android-x64` agar APK debug lebih kecil.

---

## 5. Bukti Mesin

```text
$ dart format --output=none --set-exit-if-changed lib test
Formatted 35 files (0 changed)

$ flutter analyze --fatal-infos
No issues found!

$ flutter test
00:08 +40: All tests passed!
```
