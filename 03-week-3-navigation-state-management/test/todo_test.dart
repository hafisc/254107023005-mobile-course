import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week3_navigation_state_management/main.dart';

void main() {
  testWidgets('Menambah tugas baru pada TodoPage', (tester) async {
    // Bangun aplikasi dengan membungkusnya di dalam ProviderScope
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Tunggu animasi navigasi (jika ada) selesai
    await tester.pumpAndSettle();

    // Pastikan teks default ketika daftar kosong muncul
    expect(find.text('Belum ada tugas. Tambahkan tugas baru!'), findsOneWidget);

    // Tekan tombol FAB bertanda tambah
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Temukan TextField di dalam Dialog dan isi teks
    await tester.enterText(find.byType(TextField), 'Kerjakan PR minggu 3');
    
    // Tekan tombol 'Tambah' di Dialog
    await tester.tap(find.text('Tambah'));
    
    // Pompa (pump) UI agar me-render ulang dengan data baru
    await tester.pumpAndSettle();

    // Pastikan teks default (daftar kosong) sudah hilang
    expect(find.text('Belum ada tugas. Tambahkan tugas baru!'), findsNothing);

    // Pastikan tugas yang ditambahkan muncul di daftar
    expect(find.text('Kerjakan PR minggu 3'), findsOneWidget);
  });
}
