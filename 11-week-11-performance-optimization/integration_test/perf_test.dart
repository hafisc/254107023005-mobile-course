// Skenario profiling yang SAMA dijalankan sebelum dan sesudah optimasi.
//
// Jalankan (mode profile, emulator/HP):
//   flutter drive --profile --driver=test_driver/perf_driver.dart \
//     --target=integration_test/perf_test.dart -d emulator-5554
//
// Hasil: build/<skenario>.timeline_summary.json + build/<skenario>.timeline.json
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:week11_performance_optimization/main.dart';

import 'seed.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('profiling: scroll, search, detail', (tester) async {
    await seedNotes();
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();
    expect(find.textContaining('nomor'), findsWidgets);

    final list = find.byType(Scrollable).first;

    await binding.traceAction(() async {
      for (var i = 0; i < 6; i++) {
        await tester.fling(list, const Offset(0, -1500), 4000);
        await tester.pumpAndSettle();
      }
      for (var i = 0; i < 6; i++) {
        await tester.fling(list, const Offset(0, 1500), 4000);
        await tester.pumpAndSettle();
      }
    }, reportKey: 'scroll');

    await binding.traceAction(() async {
      const query = 'belanja 1';
      final field = find.byType(TextField).first;
      for (var i = 1; i <= query.length; i++) {
        await tester.enterText(field, query.substring(0, i));
        await tester.pump(const Duration(milliseconds: 120));
      }
      await tester.pumpAndSettle();
      await tester.enterText(field, '');
      await tester.pumpAndSettle();
    }, reportKey: 'search');

    await binding.traceAction(() async {
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.textContaining('nomor').first);
        await tester.pumpAndSettle();
        expect(find.text('Detail Catatan'), findsOneWidget);
        await tester.tap(find.byTooltip('Back'));
        await tester.pumpAndSettle();
      }
    }, reportKey: 'detail');
  });
}
