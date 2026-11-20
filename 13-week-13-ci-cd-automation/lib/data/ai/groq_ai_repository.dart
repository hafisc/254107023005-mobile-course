import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../domain/entities/chat_message.dart';
import '../../domain/failures/ai_failure.dart';
import '../../domain/repositories/ai_repository.dart';

/// Model diverifikasi lewat GET https://api.groq.com/openai/v1/models.
const groqModel = 'openai/gpt-oss-20b';
const _endpoint = 'https://api.groq.com/openai/v1/chat/completions';

/// Groq memakai format OpenAI Chat Completions dengan streaming SSE.
class GroqAiRepository implements AiRepository {
  GroqAiRepository({
    required this.readApiKey,
    http.Client? client,
    this.timeout = const Duration(seconds: 20),
  }) : _client = client ?? http.Client();

  final Future<String?> Function() readApiKey;
  final http.Client _client;
  final Duration timeout;

  @override
  Stream<String> streamReply({
    required String systemPrompt,
    required List<ChatMessage> history,
  }) async* {
    final apiKey = await readApiKey();
    if (apiKey == null || apiKey.trim().isEmpty) {
      throw const AiFailure(AiFailureType.missingKey);
    }

    final request = http.Request('POST', Uri.parse(_endpoint))
      // Key lewat header Authorization, tidak pernah di URL.
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${apiKey.trim()}',
      })
      ..body = jsonEncode(buildRequestBody(systemPrompt, history));

    final http.StreamedResponse response;
    try {
      response = await _client.send(request).timeout(timeout);
    } on TimeoutException {
      throw const AiFailure(AiFailureType.offline);
    } on SocketException {
      throw const AiFailure(AiFailureType.offline);
    } on http.ClientException {
      throw const AiFailure(AiFailureType.offline);
    }

    if (response.statusCode != 200) {
      await response.stream.drain<void>();
      throw AiFailure(mapStatusCode(response.statusCode));
    }

    yield* response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .map(parseSseLine)
        .where((text) => text.isNotEmpty);
  }
}

Map<String, Object?> buildRequestBody(
  String systemPrompt,
  List<ChatMessage> history,
) => {
  'model': groqModel,
  'stream': true,
  'messages': [
    {'role': 'system', 'content': systemPrompt},
    for (final m in history)
      {
        'role': m.role == ChatRole.user ? 'user' : 'assistant',
        'content': m.text,
      },
  ],
  // Batasi token (termasuk token "berpikir" gpt-oss) untuk menekan biaya.
  'max_completion_tokens': 512,
  'reasoning_effort': 'low',
  'temperature': 0.4,
};

/// Mengambil teks jawaban dari satu baris SSE `data: {...}`.
/// Hanya `delta.content` yang diambil: gpt-oss juga mengirim
/// `delta.reasoning` (proses berpikir) yang tidak boleh tampil ke pengguna.
String parseSseLine(String line) {
  if (!line.startsWith('data:')) return '';
  final payload = line.substring(5).trim();
  if (payload.isEmpty || payload == '[DONE]') return '';
  try {
    final json = jsonDecode(payload) as Map<String, dynamic>;
    final choices = json['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) return '';
    final delta = (choices.first as Map<String, dynamic>)['delta'];
    return (delta as Map<String, dynamic>?)?['content'] as String? ?? '';
  } on FormatException {
    return '';
  }
}

AiFailureType mapStatusCode(int code) => switch (code) {
  401 || 403 => AiFailureType.invalidKey,
  429 => AiFailureType.rateLimited,
  _ => AiFailureType.server,
};
