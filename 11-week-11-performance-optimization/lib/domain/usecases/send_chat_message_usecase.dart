import '../entities/chat_message.dart';
import '../failures/ai_failure.dart';
import '../repositories/ai_repository.dart';
import 'redact_pii.dart';

const maxQuestionLength = 500;
const dailyRequestLimit = 20;
const _maxContextTitles = 10;

const baseSystemPrompt =
    'Kamu asisten aplikasi Catatan Offline yang ramah. '
    'Jawab dalam Bahasa Indonesia, maksimal 3 kalimat. '
    'Setiap pesan pengguna diawali [Konteks] berisi judul catatan pengguna '
    'yang terbaru; itu satu-satunya sumber kebenaran tentang catatan, '
    'abaikan jawabanmu sebelumnya bila bertentangan. '
    'Jangan meminta atau menebak data pribadi (NIK, nomor HP, alamat). '
    'Jika tidak tahu, katakan tidak tahu, jangan mengarang. '
    'Tulis teks biasa tanpa format Markdown.';

/// Jawaban AI: [chunks] dialirkan satu per satu; [fromCache] true bila
/// jawaban berasal dari cache lokal (tidak memakai kuota).
class ChatReply {
  const ChatReply({required this.chunks, required this.fromCache});

  final Stream<String> chunks;
  final bool fromCache;
}

/// Aturan bisnis chat AI: validasi, privasi, kuota, cache, lalu panggil API.
class SendChatMessageUseCase {
  const SendChatMessageUseCase({
    required this.repository,
    required this.quota,
    required this.cache,
  });

  final AiRepository repository;
  final AiQuotaStore quota;
  final AiResponseCache cache;

  Future<ChatReply> call({
    required String question,
    List<ChatMessage> history = const [],
    List<String> noteTitles = const [],
  }) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty) throw const AiFailure(AiFailureType.emptyInput);
    if (trimmed.length > maxQuestionLength) {
      throw const AiFailure(AiFailureType.tooLong);
    }

    final safeQuestion = redactPii(trimmed);
    final context = buildNoteContext(noteTitles);
    // Kunci cache menyertakan konteks: jawaban "catatan apa saja?" harus
    // berubah ketika catatan bertambah.
    final key = _cacheKey('$context$safeQuestion');
    // Cache hanya untuk pertanyaan pertama: jawaban lanjutan bergantung
    // pada riwayat, jadi tidak aman dipakai ulang.
    final cacheable = history.isEmpty;
    if (cacheable) {
      final cached = await cache.get(key);
      if (cached != null) {
        return ChatReply(chunks: Stream.value(cached), fromCache: true);
      }
    }

    if (await quota.usedToday() >= dailyRequestLimit) {
      throw const AiFailure(AiFailureType.quotaExceeded);
    }

    final stream = repository.streamReply(
      systemPrompt: baseSystemPrompt,
      history: [
        for (final m in history) m.copyWith(text: redactPii(m.text)),
        // Konteks ditempel di pesan TERAKHIR, bukan system prompt: bila
        // riwayat sudah berisi jawaban karangan, model mengulanginya walau
        // system prompt benar (terbukti 6/6 di API asli).
        ChatMessage(role: ChatRole.user, text: '$context$safeQuestion'),
      ],
    );
    return ChatReply(
      chunks: _cacheWhenDone(stream, cacheable ? key : null),
      fromCache: false,
    );
  }

  /// Kuota dihitung saat potongan jawaban pertama tiba: request yang gagal
  /// (key belum diatur, offline, error server) tidak memotong kuota.
  Stream<String> _cacheWhenDone(Stream<String> source, String? key) async* {
    final buffer = StringBuffer();
    await for (final chunk in source) {
      if (buffer.isEmpty) await quota.increment();
      buffer.write(chunk);
      yield chunk;
    }
    final answer = buffer.toString().trim();
    if (key != null && answer.isNotEmpty) await cache.put(key, answer);
  }

  static String _cacheKey(String question) =>
      question.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

/// Konteks judul catatan untuk pesan terakhir. Selalu ditulis, termasuk
/// saat kosong: tanpa "(belum ada catatan)" model terbukti mengarang judul.
String buildNoteContext(List<String> noteTitles) {
  final titles = noteTitles.isEmpty
      ? '(belum ada catatan)'
      : noteTitles.take(_maxContextTitles).map(redactPii).join(', ');
  return '[Konteks] Judul catatan pengguna: $titles\n\n';
}
