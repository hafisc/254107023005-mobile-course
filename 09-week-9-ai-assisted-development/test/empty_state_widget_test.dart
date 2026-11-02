import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week9_ai_assisted_development/widgets/empty_state.dart';

void main() {
  group('EmptyStateWidget Tests', () {
    testWidgets('menampilkan pesan dan icon dengan benar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              message: 'Tidak ada catatan yang cocok',
              icon: Icons.search_off_rounded,
            ),
          ),
        ),
      );

      expect(find.text('Tidak ada catatan yang cocok'), findsOneWidget);
      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('menampilkan tombol aksi dan memicu callback ketika ditekan', (
      tester,
    ) async {
      var actionTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              message: 'Tidak ada hasil',
              actionLabel: 'Hapus Pencarian',
              onAction: () {
                actionTriggered = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Hapus Pencarian'), findsOneWidget);

      await tester.tap(find.text('Hapus Pencarian'));
      await tester.pump();

      expect(actionTriggered, isTrue);
    });
  });
}
