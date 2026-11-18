import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week10_ai_feature_integration/data/ai/ai_providers.dart';
import 'package:week10_ai_feature_integration/data/local/note.dart';
import 'package:week10_ai_feature_integration/data/providers.dart';
import 'package:week10_ai_feature_integration/domain/failures/ai_failure.dart';
import 'package:week10_ai_feature_integration/domain/usecases/send_chat_message_usecase.dart';
import 'package:week10_ai_feature_integration/pages/chat_page.dart';

import 'send_chat_message_usecase_test.dart'
    show FakeAiRepository, FakeCache, FakeQuota;

class _FakeNotes extends NotesNotifier {
  @override
  Future<List<Note>> build() async => [
    Note(title: 'Jadwal rapat PBL', updatedAt: DateTime(2026)),
    Note(title: 'Belanja bulanan', updatedAt: DateTime(2026)),
  ];
}

Widget _app(FakeAiRepository repo) => ProviderScope(
  overrides: [
    notesProvider.overrideWith(_FakeNotes.new),
    aiQuotaUsedProvider.overrideWith((ref) async => 0),
    sendChatMessageUseCaseProvider.overrideWithValue(
      SendChatMessageUseCase(
        repository: repo,
        quota: FakeQuota(),
        cache: FakeCache(),
      ),
    ),
  ],
  child: const MaterialApp(home: ChatPage()),
);

Future<void> _ask(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.tap(find.byTooltip('Kirim'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('jawaban AI tampil sebagai bubble', (tester) async {
    await tester.pumpWidget(_app(FakeAiRepository()));
    await tester.pumpAndSettle();

    await _ask(tester, 'Halo');

    expect(find.text('Halo'), findsOneWidget);
    expect(find.text('Halo dunia'), findsOneWidget);
  });

  testWidgets(
    'AI offline: pesan ramah, coba lagi, dan fallback catatan lokal',
    (tester) async {
      final repo = FakeAiRepository(
        error: const AiFailure(AiFailureType.offline),
      );
      await tester.pumpWidget(_app(repo));
      await tester.pumpAndSettle();

      await _ask(tester, 'kapan rapat pbl?');

      expect(find.textContaining('Mode offline aktif'), findsOneWidget);
      expect(find.text('Coba lagi'), findsOneWidget);
      expect(find.text('• Jadwal rapat PBL'), findsOneWidget);
      expect(find.text('• Belanja bulanan'), findsNothing);
    },
  );
  testWidgets('pertanyaan gagal lalu dikirim ulang tidak muncul dobel', (
    tester,
  ) async {
    final repo = FakeAiRepository(
      error: const AiFailure(AiFailureType.offline),
    );
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    await _ask(tester, 'hi');
    expect(find.text('hi'), findsOneWidget);

    await _ask(tester, 'hi');
    expect(find.text('hi'), findsOneWidget);
    expect(repo.lastHistory, hasLength(1));
  });
}
