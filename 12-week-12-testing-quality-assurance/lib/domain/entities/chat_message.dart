enum ChatRole { user, assistant }

/// Satu pesan di percakapan. Pure Dart: tidak bergantung pada Flutter/http.
class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.text,
    this.fromCache = false,
  });

  final ChatRole role;
  final String text;

  /// true jika jawaban diambil dari cache lokal (tanpa memanggil API).
  final bool fromCache;

  ChatMessage copyWith({String? text, bool? fromCache}) => ChatMessage(
    role: role,
    text: text ?? this.text,
    fromCache: fromCache ?? this.fromCache,
  );
}
