import 'package:flutter_test/flutter_test.dart';
import 'package:week13_ci_cd_automation/domain/entities/chat_message.dart';
import 'package:week13_ci_cd_automation/domain/failures/ai_failure.dart';
import 'package:week13_ci_cd_automation/domain/repositories/ai_repository.dart';
import 'package:week13_ci_cd_automation/domain/usecases/send_chat_message_usecase.dart';

class FakeAiRepository implements AiRepository {
  FakeAiRepository({this.chunks = const ['Halo', ' dunia'], this.error});

  final List<String> chunks;
  final AiFailure? error;
  int calls = 0;
  List<ChatMessage> lastHistory = [];
  String lastSystemPrompt = '';

  @override
  Stream<String> streamReply({
    required String systemPrompt,
    required List<ChatMessage> history,
  }) async* {
    calls++;
    lastHistory = history;
    lastSystemPrompt = systemPrompt;
    if (error != null) throw error!;
    yield* Stream.fromIterable(chunks);
  }
}

class FakeQuota implements AiQuotaStore {
  FakeQuota([this.used = 0]);
  int used;

  @override
  Future<int> usedToday() async => used;

  @override
  Future<void> increment() async => used++;
}

class FakeCache implements AiResponseCache {
  final map = <String, String>{};

  @override
  Future<String?> get(String question) async => map[question];

  @override
  Future<void> put(String question, String answer) async =>
      map[question] = answer;
}

void main() {
  late FakeAiRepository repo;
  late FakeQuota quota;
  late FakeCache cache;
  late SendChatMessageUseCase useCase;

  setUp(() {
    repo = FakeAiRepository();
    quota = FakeQuota();
    cache = FakeCache();
    useCase = SendChatMessageUseCase(
      repository: repo,
      quota: quota,
      cache: cache,
    );
  });

  test('sukses: chunk dialirkan, kuota bertambah, jawaban di-cache', () async {
    final reply = await useCase(question: 'Apa kabar?');
    expect(await reply.chunks.join(), 'Halo dunia');
    expect(reply.fromCache, isFalse);
    expect(quota.used, 1);
    expect(cache.map.values.single, 'Halo dunia');
  });

  test('pertanyaan sama kedua kali diambil dari cache tanpa API', () async {
    await (await useCase(question: 'Apa kabar?')).chunks.join();
    final second = await useCase(question: '  APA   kabar? ');
    expect(second.fromCache, isTrue);
    expect(await second.chunks.join(), 'Halo dunia');
    expect(repo.calls, 1);
    expect(quota.used, 1);
  });

  test('data pribadi disamarkan sebelum dikirim ke API', () async {
    await (await useCase(
      question: 'Simpan nomor 081234567890 dan NIK 3573012345678901',
      noteTitles: ['Kontak budi@mail.com'],
    )).chunks.join();
    final sent = repo.lastHistory.last.text;
    expect(sent, isNot(contains('0812')));
    expect(sent, contains('[TELEPON]'));
    expect(sent, contains('[NIK]'));
    expect(sent, contains('[EMAIL]'));
    expect(sent, isNot(contains('budi@mail.com')));
  });

  test('input kosong ditolak tanpa memanggil API', () async {
    expect(
      () => useCase(question: '   '),
      throwsA(
        isA<AiFailure>().having(
          (f) => f.type,
          'type',
          AiFailureType.emptyInput,
        ),
      ),
    );
    expect(repo.calls, 0);
  });

  test('input > 500 karakter ditolak', () async {
    expect(() => useCase(question: 'a' * 501), throwsA(isA<AiFailure>()));
  });

  test('kuota harian habis: tidak memanggil API', () async {
    quota.used = dailyRequestLimit;
    await expectLater(
      useCase(question: 'Halo'),
      throwsA(
        isA<AiFailure>().having(
          (f) => f.type,
          'type',
          AiFailureType.quotaExceeded,
        ),
      ),
    );
    expect(repo.calls, 0);
  });

  test('error API diteruskan dan jawaban gagal tidak di-cache', () async {
    repo = FakeAiRepository(error: const AiFailure(AiFailureType.offline));
    useCase = SendChatMessageUseCase(
      repository: repo,
      quota: quota,
      cache: cache,
    );
    final reply = await useCase(question: 'Halo');
    await expectLater(reply.chunks.join(), throwsA(isA<AiFailure>()));
    expect(cache.map, isEmpty);
    // Request gagal tidak boleh memotong kuota (ditemukan saat uji manual).
    expect(quota.used, 0);
  });

  test('pertanyaan lanjutan (ada riwayat) tidak memakai cache', () async {
    final reply = await useCase(
      question: 'Lalu?',
      history: const [ChatMessage(role: ChatRole.user, text: 'Halo')],
    );
    expect(reply.fromCache, isFalse);
    // Stream async* bersifat lazy: request baru terjadi saat di-listen.
    await reply.chunks.join();
    expect(repo.lastHistory, hasLength(2));
  });
  test('tanpa catatan: "(belum ada catatan)" ada di pesan terakhir', () async {
    await (await useCase(question: 'Catatan apa saja?')).chunks.join();
    expect(repo.lastHistory.last.text, contains('(belum ada catatan)'));
    expect(repo.lastHistory.last.text, endsWith('Catatan apa saja?'));
    expect(repo.lastSystemPrompt, contains('tanpa format Markdown'));
  });

  test('cache tidak dipakai bila daftar catatan berubah', () async {
    await (await useCase(question: 'Catatan apa saja?')).chunks.join();
    final after = await useCase(
      question: 'Catatan apa saja?',
      noteTitles: ['Tugas Mobile'],
    );
    expect(after.fromCache, isFalse);
    await after.chunks.join();
    expect(repo.calls, 2);
    expect(repo.lastHistory.last.text, contains('Tugas Mobile'));
  });
}
