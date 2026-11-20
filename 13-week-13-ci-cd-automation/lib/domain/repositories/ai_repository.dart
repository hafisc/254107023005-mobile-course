import '../entities/chat_message.dart';

/// Kontrak ke model AI. Implementasi (Groq via http) ada di layer data.
abstract interface class AiRepository {
  /// Mengalirkan potongan teks jawaban (streaming).
  /// Melempar `AiFailure` bila gagal.
  Stream<String> streamReply({
    required String systemPrompt,
    required List<ChatMessage> history,
  });
}

/// Penghitung pemakaian harian untuk membatasi biaya.
abstract interface class AiQuotaStore {
  Future<int> usedToday();
  Future<void> increment();
}

/// Cache jawaban lokal agar pertanyaan yang sama tidak memanggil API lagi.
abstract interface class AiResponseCache {
  Future<String?> get(String question);
  Future<void> put(String question, String answer);
}
