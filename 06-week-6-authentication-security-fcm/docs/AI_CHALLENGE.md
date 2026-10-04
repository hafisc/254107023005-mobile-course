# AI Challenge - Week 6

## 1. Prompt yang digunakan
```
Aplikasi Flutter Campus Notification App.
Stack: firebase_messaging, flutter_local_notifications,
flutter_secure_storage, go_router, Riverpod.
Buatkan PushService dengan:
- requestPermission + getToken + onTokenRefresh (kirim ke POST /devices)
- onMessage (tampilkan local notification manual)
- onMessageOpenedApp + getInitialMessage (navigasi ke data.route)
- subscribe/unsubscribe topic pengumuman-kampus
- background handler top-level dengan @pragma('vm:entry-point')
Tandai bagian yang BERBEDA untuk Android 13+ vs iOS,
dan bagian yang tidak boleh mengakses BuildContext.
```

## 2. Output Awal AI
AI memberikan implementasi dasar dari `PushService`.

## 3. Perbaikan Manual dan Verifikasi
Berikut ini adalah hasil verifikasi:
1. **Background handler top-level**: Sudah dipastikan berupa fungsi top-level dan menggunakan `@pragma('vm:entry-point')`.
2. **onTokenRefresh**: Kode AI hanya melakukan print, sehingga kami menyesuaikannya untuk menyimpan ke backend simulasi via argumen callback `onToken`.
3. **Foreground local notification**: Kami memperbaiki syntax inisialisasi `flutter_local_notifications` karena AI menggunakan argument positional pada versi terbaru yang mengharuskan named argument.
4. **Klik navigasi (Foreground/Background/Terminated)**: Kami memastikan `onMessageOpenedApp` dan `getInitialMessage` mengirim rute yang benar.
5. **Keamanan Token**: Tidak ada hardcode secret dan token disimpan/dilog sebagian (substring 12 karakter) atau langsung diproses backend.

## 4. Alasan Teknis
Saya menolak draf awal AI terkait syntax inisialisasi plugin karena AI belum menggunakan sintaks named parameter pada versi terbaru `flutter_local_notifications` v20. Selain itu, saya memisahkan routing logika dari dalam `PushService` menggunakan callback (seperti `listenForeground(Function(String) go)`), agar `PushService` tetap netral dan tidak bergantung secara langsung pada `GoRouter` atau `BuildContext`.
