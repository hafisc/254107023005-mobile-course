enum AiFailureType {
  emptyInput,
  tooLong,
  missingKey,
  invalidKey,
  quotaExceeded,
  rateLimited,
  offline,
  server,
}

/// Kegagalan fitur AI yang sudah diterjemahkan ke pesan ramah pengguna.
class AiFailure implements Exception {
  const AiFailure(this.type);

  final AiFailureType type;

  /// Fallback ke data lokal masuk akal bila AI tidak bisa dihubungi,
  /// bukan bila input pengguna yang salah.
  bool get canFallback =>
      type != AiFailureType.emptyInput && type != AiFailureType.tooLong;

  String get message => switch (type) {
    AiFailureType.emptyInput => 'Pertanyaan tidak boleh kosong.',
    AiFailureType.tooLong => 'Pertanyaan terlalu panjang (maks 500 karakter).',
    AiFailureType.missingKey =>
      'API key belum diatur. Buka Pengaturan untuk menambahkannya.',
    AiFailureType.invalidKey =>
      'API key ditolak server. Periksa kembali di Pengaturan.',
    AiFailureType.quotaExceeded =>
      'Batas pertanyaan AI hari ini sudah habis. Coba lagi besok.',
    AiFailureType.rateLimited =>
      'Layanan AI sedang sibuk. Tunggu sebentar lalu coba lagi.',
    AiFailureType.offline => 'Tidak ada koneksi internet. Mode offline aktif.',
    AiFailureType.server => 'Layanan AI sedang bermasalah. Coba lagi nanti.',
  };

  @override
  String toString() => 'AiFailure($type)';
}
