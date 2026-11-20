# Refleksi - Week 12: Pengujian dan Jaminan Kualitas

**Tanggal**: 20 November 2026

---

### 1. Bug apa yang paling mungkin terlewat tanpa pengujian yang Anda tulis?

Error `setState() called during build` saat kembali dari form tambah catatan. Di emulator, catatan tetap tersimpan dan tampil, jadi kelihatannya tidak ada masalah; error hanya muncul sebagai pesan di konsol debug. Widget test menangkapnya karena framework test menggagalkan test bila ada exception, walaupun UI-nya terlihat benar. Bug lain yang mudah terlewat adalah error simpan yang "ditelan" diam-diam (form tertutup seolah berhasil) dan penghitungan panjang judul dengan `.length` yang salah menolak judul berisi emoji.

### 2. Bagian mana yang perlu fake, dan bagaimana fake itu membuat pengujian lebih konsisten?

Sumber data catatan (`NoteRepository`). Dengan `FakeNoteRepository` saya bisa:

- memaksa kegagalan tertentu (`addError`, `fetchError`) yang sulit dibuat dengan SQLite asli;
- menahan operasi dengan `Completer` untuk melihat loading dan tombol nonaktif tanpa `Future.delayed`;
- memeriksa apa yang benar-benar dikirim ke repository (misalnya judul sudah di-trim).

Hasilnya sama setiap kali dijalankan, tidak bergantung pada isi database di perangkat, dan semua test unit/widget selesai dalam hitungan detik.

### 3. Apa perbedaan nilai yang diberikan pengujian widget dan pengujian integrasi pada fitur Anda?

Widget test cepat dan bisa menguji banyak keadaan (validasi, error, loading, dobel simpan), tetapi memakai fake, jadi tidak membuktikan data sungguh tersimpan. Integration test lambat dan hanya satu alur, tetapi membuktikan semuanya bekerja bersama di perangkat: form, router, Riverpod, dan SQLite asli. Integration test juga menemukan masalah yang tidak muncul di widget test, yaitu finder yang ikut mencocokkan isi kolom search.
