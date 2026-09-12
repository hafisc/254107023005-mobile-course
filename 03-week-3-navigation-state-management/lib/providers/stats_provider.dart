import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// AsyncNotifier untuk mengelola state statistik asinkron (Tugas AI Challenge)
class StatsNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    return _fetchStats();
  }

  Future<void> refresh() async {
    // Set state ke loading sementara me-refresh
    state = const AsyncLoading();
    // Gunakan AsyncValue.guard untuk otomatis menangani success & error (exception)
    state = await AsyncValue.guard(() => _fetchStats());
  }

  Future<List<String>> _fetchStats() async {
    // Simulasi delay jaringan selama 2 detik
    await Future.delayed(const Duration(seconds: 2));

    // Simulasi kegagalan acak 30%
    final random = Random();
    if (random.nextDouble() < 0.3) {
      throw Exception('Gagal terhubung ke server untuk mengambil data statistik.');
    }

    // Jika berhasil, kembalikan data
    return [
      'Total Tugas Selesai: 42',
      'Tugas Tertunda: 15',
      'Produktivitas Minggu Ini: 85%',
      'Rata-rata Waktu Penyelesaian: 4 Jam',
    ];
  }
}

// Provider untuk StatsNotifier
final statsProvider = AsyncNotifierProvider<StatsNotifier, List<String>>(() {
  return StatsNotifier();
});
