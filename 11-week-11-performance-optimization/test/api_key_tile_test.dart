import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week11_performance_optimization/data/ai/ai_local_stores.dart';
import 'package:week11_performance_optimization/data/ai/ai_providers.dart';
import 'package:week11_performance_optimization/widgets/api_key_tile.dart';

class _FakeKeyStore extends ApiKeyStore {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> save(String v) async => value = v;

  @override
  Future<void> delete() async => value = null;
}

void main() {
  testWidgets('simpan API key: dialog tertutup tanpa error, status berubah', (
    tester,
  ) async {
    final store = _FakeKeyStore();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiKeyStoreProvider.overrideWithValue(store),
          aiQuotaUsedProvider.overrideWith((ref) async => 3),
        ],
        child: const MaterialApp(home: Scaffold(body: ApiKeyTile())),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Belum diatur'), findsOneWidget);
    expect(find.text('3 / 20 pertanyaan terpakai'), findsOneWidget);

    await tester.tap(find.text('API Key Groq'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '  gsk_TEST  ');
    await tester.tap(find.text('Simpan'));
    // Sebelum perbaikan, animasi tutup dialog memicu assertion
    // `_dependents.isEmpty` karena controller sudah di-dispose.
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(store.value, 'gsk_TEST');
    expect(find.text('Tersimpan aman (terenkripsi)'), findsOneWidget);
  });

  testWidgets('batal: key tidak disimpan', (tester) async {
    final store = _FakeKeyStore();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiKeyStoreProvider.overrideWithValue(store),
          aiQuotaUsedProvider.overrideWith((ref) async => 0),
        ],
        child: const MaterialApp(home: Scaffold(body: ApiKeyTile())),
      ),
    );
    await tester.tap(find.text('API Key Groq'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'gsk_TEST');
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();

    expect(store.value, isNull);
  });
}
