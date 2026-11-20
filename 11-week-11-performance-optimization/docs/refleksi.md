# Refleksi - Week 11: Optimasi Performa

**Tanggal**: 18 November 2026

---

### 1. Optimasi mana yang memberikan dampak terbesar dan mengapa?

Query detail berdasarkan id (`WHERE id = ? LIMIT 1`). Versi lama memuat 2.000 baris dari SQLite, mengubah semuanya menjadi objek `Note`, lalu membuang 1.999 di antaranya. Di emulator, operasi itu turun dari sekitar 35 ms menjadi 3,9 ms, dan waktu garbage collection di skenario detail turun dari sekitar 78 ms menjadi 25 ms. Dampaknya besar karena yang dihilangkan adalah pekerjaan yang memang tidak perlu, bukan pekerjaan yang dibuat sedikit lebih cepat.

### 2. Bagaimana Anda memverifikasi bahwa optimasi benar-benar bekerja (bukan placebo)?

Perbandingan pertama saya ternyata placebo: detail terlihat 2,5x lebih cepat, tetapi kode lama yang diukur ulang belakangan sama cepatnya. Emulator hanya sedang lebih cepat. Setelah itu saya memakai aturan:

- skenario yang sama persis di satu file test;
- run bergantian lama/baru dengan build bersih, plus memastikan isi APK memang versi yang dimaksud (pernah terjadi Flutter memakai binary lama);
- skenario scroll yang kodenya tidak diubah sebagai kelompok kontrol untuk melihat besarnya noise;
- metrik yang pasti (jumlah rebuild, jumlah request, ukuran payload) di samping frame time;
- kontrol negatif: leak test baru saya percaya setelah terbukti gagal ketika `dispose()` sengaja dihapus.

### 3. Trade-off apa yang Anda hadapi?

- **Debounce search**: rebuild dan CPU turun, tetapi hasil muncul 250 ms lebih lambat, dan pekerjaan menumpuk di satu frame (frame terburuk search malah naik).
- **Indeks pencarian**: lebih cepat per ketikan, tetapi memakai memori tambahan (satu string per catatan) dan menambah kode yang harus dijaga agar hasilnya sama dengan versi lama. Karena itu saya menambah test kesetaraan.
- **Memecah `NotesPage`** jadi beberapa widget: rebuild jauh berkurang, tetapi struktur file lebih panjang, dan sinkronisasi tombol "Hapus Pencarian" dengan kolom search jadi perlu `ref.listen`.
- **Throttle refresh posts 5 menit**: request jaringan berkurang, tetapi data bisa tertinggal sampai 5 menit kecuali pengguna menekan refresh.

### 4. Kapan sebaiknya optimasi premature dihindari?

Ketika belum ada bukti dari profiling. Optimasi search adalah contohnya: secara teori benar (4.000 string per ketikan), tetapi ongkos aslinya hanya 0,93 ms, sehingga frame time tidak berubah. Saya juga sempat menduga `openNotesDb()` membuka database berulang kali, ternyata `sqflite` sudah memakai satu koneksi (`singleInstance: true`). Pagination juga saya tunda karena `ListView.builder` sudah cukup untuk 2.000 catatan. Ukur dulu, optimasi yang terbukti mahal, lalu ukur lagi.
