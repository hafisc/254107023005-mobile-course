import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:week11_performance_optimization/data/ai/groq_ai_repository.dart';
import 'package:week11_performance_optimization/domain/entities/chat_message.dart';
import 'package:week11_performance_optimization/domain/failures/ai_failure.dart';

const _history = [ChatMessage(role: ChatRole.user, text: 'Halo')];

/// Satu baris SSE dengan format yang sama seperti respons asli Groq.
String _sse(Map<String, Object?> delta) =>
    'data: ${jsonEncode({
      'object': 'chat.completion.chunk',
      'choices': [
        {'index': 0, 'delta': delta, 'finish_reason': null},
      ],
    })}\n\n';

GroqAiRepository _repo(MockClient client, {String? key = 'TEST_KEY'}) =>
    GroqAiRepository(readApiKey: () async => key, client: client);

void main() {
  test('streaming: hanya content yang diambil, reasoning diabaikan', () async {
    late http.BaseRequest captured;
    final client = MockClient.streaming((request, body) async {
      captured = request;
      return http.StreamedResponse(
        Stream.fromIterable([
          utf8.encode(_sse({'role': 'assistant', 'content': ''})),
          utf8.encode(_sse({'reasoning': 'Need respond', 'channel': 'x'})),
          utf8.encode(_sse({'content': 'Halo'})),
          utf8.encode(_sse({'content': ', apa kabar?'})),
          utf8.encode('data: [DONE]\n\n'),
        ]),
        200,
      );
    });

    final chunks = await _repo(
      client,
    ).streamReply(systemPrompt: 'sys', history: _history).toList();

    expect(chunks, ['Halo', ', apa kabar?']);
    expect(chunks.join(), isNot(contains('Need')));
    expect(captured.headers['Authorization'], 'Bearer TEST_KEY');
    expect(captured.url.toString(), isNot(contains('TEST_KEY')));
  });

  test('API key kosong -> missingKey tanpa request', () async {
    var called = false;
    final client = MockClient((_) async {
      called = true;
      return http.Response('', 200);
    });
    await expectLater(
      _repo(client, key: null).streamReply(systemPrompt: 's', history: []),
      emitsError(
        isA<AiFailure>().having((f) => f.type, 't', AiFailureType.missingKey),
      ),
    );
    expect(called, isFalse);
  });

  for (final (code, type) in [
    (401, AiFailureType.invalidKey),
    (429, AiFailureType.rateLimited),
    (503, AiFailureType.server),
  ]) {
    test('HTTP $code dipetakan ke $type', () async {
      final client = MockClient((_) async => http.Response('{}', code));
      await expectLater(
        _repo(client).streamReply(systemPrompt: 's', history: _history),
        emitsError(isA<AiFailure>().having((f) => f.type, 't', type)),
      );
    });
  }

  test('gagal koneksi -> offline', () async {
    final client = MockClient((_) => throw http.ClientException('no net'));
    await expectLater(
      _repo(client).streamReply(systemPrompt: 's', history: _history),
      emitsError(
        isA<AiFailure>().having((f) => f.type, 't', AiFailureType.offline),
      ),
    );
  });

  test('parseSseLine mengabaikan baris non-data, [DONE], dan JSON rusak', () {
    expect(parseSseLine(''), '');
    expect(parseSseLine(': ping'), '');
    expect(parseSseLine('data: [DONE]'), '');
    expect(parseSseLine('data: {rusak'), '');
    expect(parseSseLine('data: {"choices":[]}'), '');
  });

  test(
    'body request: system prompt di depan, jawaban AI ber-role assistant',
    () {
      final body = buildRequestBody('sys', const [
        ChatMessage(role: ChatRole.user, text: 'a'),
        ChatMessage(role: ChatRole.assistant, text: 'b'),
      ]);
      final messages = body['messages']! as List;
      expect(messages.first, {'role': 'system', 'content': 'sys'});
      expect((messages[2] as Map)['role'], 'assistant');
      expect(body['model'], groqModel);
      expect(body['stream'], isTrue);
    },
  );
}
