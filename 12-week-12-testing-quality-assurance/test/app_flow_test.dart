import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:week12_testing_quality_assurance/data/ai/ai_local_stores.dart';
import 'package:week12_testing_quality_assurance/data/ai/ai_providers.dart';
import 'package:week12_testing_quality_assurance/data/local/note.dart';
import 'package:week12_testing_quality_assurance/data/providers.dart';
import 'package:week12_testing_quality_assurance/main.dart';

class _FakeKeyStore extends ApiKeyStore {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> save(String v) async => value = v;
}

class _FakeNotes extends NotesNotifier {
  @override
  Future<List<Note>> build() async => [
    Note(title: 'Catatan Baru', updatedAt: DateTime(2026)),
  ];
}

void main() {
  testWidgets('alur nyata: chat -> Buka Pengaturan -> simpan key', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = _FakeKeyStore();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiKeyStoreProvider.overrideWithValue(store),
          notesProvider.overrideWith(_FakeNotes.new),
          dirtyCountProvider.overrideWith((ref) async => 0),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Asisten AI'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Halo');
    await tester.tap(find.byTooltip('Kirim'));
    await tester.pumpAndSettle();
    expect(find.textContaining('API key belum diatur'), findsOneWidget);

    await tester.tap(find.text('Buka Pengaturan'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'setelah Buka Pengaturan');

    await tester.tap(find.text('API Key Groq'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'gsk_TEST');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull, reason: 'setelah Simpan');
    expect(store.value, 'gsk_TEST');
    expect(find.text('Tersimpan aman (terenkripsi)'), findsOneWidget);
  });
}
