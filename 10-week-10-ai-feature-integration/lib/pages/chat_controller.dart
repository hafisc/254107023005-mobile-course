import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/ai/ai_providers.dart';
import '../data/local/note.dart';
import '../data/providers.dart';
import '../domain/entities/chat_message.dart';
import '../domain/failures/ai_failure.dart';
import '../domain/usecases/filter_notes_usecase.dart';

class ChatState {
  const ChatState({
    this.messages = const [],
    this.isStreaming = false,
    this.failure,
    this.fallbackNotes = const [],
    this.lastQuestion,
  });

  final List<ChatMessage> messages;
  final bool isStreaming;
  final AiFailure? failure;

  /// Catatan lokal yang relevan, ditampilkan saat AI gagal (mode offline).
  final List<Note> fallbackNotes;
  final String? lastQuestion;
}

class ChatController extends Notifier<ChatState> {
  @override
  ChatState build() => const ChatState();

  Future<void> send(String question) async {
    if (state.isStreaming) return;
    // Buang pertanyaan sebelumnya yang gagal (belum terjawab) agar tidak
    // muncul dobel dan tidak ikut terkirim sebagai riwayat.
    final history = [...state.messages];
    if (state.failure != null &&
        history.isNotEmpty &&
        history.last.role == ChatRole.user) {
      history.removeLast();
    }
    final userMessage = ChatMessage(role: ChatRole.user, text: question.trim());

    state = ChatState(
      messages: [...history, userMessage],
      isStreaming: true,
      lastQuestion: question,
    );

    // Tunggu catatan selesai dimuat; `.value` bisa null jika chat dibuka
    // sebelum daftar catatan sempat tampil (bug ditemukan lewat widget test).
    var notes = const <Note>[];
    try {
      notes = await ref.read(notesProvider.future);
    } catch (_) {
      // Database gagal dibaca: chat tetap jalan tanpa konteks catatan.
    }
    if (!ref.mounted) return;

    try {
      final reply = await ref
          .read(sendChatMessageUseCaseProvider)
          .call(
            question: question,
            history: history,
            noteTitles: notes.map((n) => n.title).toList(),
          );
      var answer = ChatMessage(
        role: ChatRole.assistant,
        text: '',
        fromCache: reply.fromCache,
      );
      await for (final chunk in reply.chunks) {
        if (!ref.mounted) return;
        answer = answer.copyWith(text: answer.text + chunk);
        state = _with(messages: [...history, userMessage, answer]);
      }
      if (answer.text.trim().isEmpty) {
        throw const AiFailure(AiFailureType.server);
      }
    } on AiFailure catch (f) {
      if (!ref.mounted) return;
      _fail(f, question, notes);
    } catch (_) {
      if (!ref.mounted) return;
      _fail(const AiFailure(AiFailureType.server), question, notes);
    } finally {
      if (ref.mounted) {
        state = _with(isStreaming: false);
        ref.invalidate(aiQuotaUsedProvider);
      }
    }
  }

  /// Kirim ulang pertanyaan terakhir yang gagal.
  Future<void> retry() async {
    final question = state.lastQuestion;
    if (question == null) return;
    // send() sudah membuang pertanyaan gagal sebelumnya dari riwayat.
    await send(question);
  }

  void clear() => state = const ChatState();

  void _fail(AiFailure f, String question, List<Note> notes) {
    state = ChatState(
      messages: state.messages,
      isStreaming: state.isStreaming,
      failure: f,
      fallbackNotes: f.canFallback ? searchNotesByWords(notes, question) : [],
      lastQuestion: question,
    );
  }

  ChatState _with({List<ChatMessage>? messages, bool? isStreaming}) =>
      ChatState(
        messages: messages ?? state.messages,
        isStreaming: isStreaming ?? state.isStreaming,
        failure: state.failure,
        fallbackNotes: state.fallbackNotes,
        lastQuestion: state.lastQuestion,
      );
}

final chatControllerProvider = NotifierProvider<ChatController, ChatState>(
  ChatController.new,
);

/// Fallback lokal: catatan yang memuat salah satu kata (>= 3 huruf) dari
/// pertanyaan, memakai ulang `filterNotes` dari Minggu 9.
List<Note> searchNotesByWords(List<Note> notes, String question) {
  final words = question
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9]+'))
      .where((w) => w.length >= 3)
      .toSet();
  final found = <Note>{};
  for (final w in words) {
    found.addAll(filterNotes(notes, w));
  }
  return found.take(5).toList();
}
