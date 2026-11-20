// Mengukur jumlah rebuild per widget saat mengetik di kolom search.
// `debugOnRebuildDirtyWidget` dipanggil Flutter setiap kali sebuah Element
// di-rebuild, jadi angkanya pasti (bukan perkiraan dari timeline).
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week11_performance_optimization/data/local/note.dart';
import 'package:week11_performance_optimization/data/providers.dart';
import 'package:week11_performance_optimization/pages/notes_page.dart';

const _watched = {
  'NotesPage',
  'NoteTile',
  'AppBar',
  'TextField',
  'EmptyStateWidget',
  'Badge',
};

class _ManyNotes extends NotesNotifier {
  @override
  Future<List<Note>> build() async => [
    for (var i = 0; i < 2000; i++)
      Note(
        id: i,
        title: i % 10 == 0 ? 'Belanja minggu $i' : 'Catatan nomor $i',
        body: 'Isi catatan ke-$i',
        updatedAt: DateTime(2026),
        dirty: i.isEven,
      ),
  ];
}

Future<Map<String, int>> countRebuildsWhileTyping(
  WidgetTester tester,
  String query,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        notesProvider.overrideWith(_ManyNotes.new),
        dirtyCountProvider.overrideWith((ref) async => 1000),
      ],
      child: const MaterialApp(home: NotesPage()),
    ),
  );
  await tester.pumpAndSettle();

  final counts = <String, int>{};
  widgets.debugOnRebuildDirtyWidget = (element, builtOnce) {
    final name = element.widget.runtimeType.toString();
    if (_watched.contains(name)) counts[name] = (counts[name] ?? 0) + 1;
  };
  final field = find.byType(TextField).first;
  for (var i = 1; i <= query.length; i++) {
    await tester.enterText(field, query.substring(0, i));
    await tester.pump(const Duration(milliseconds: 120));
  }
  // Beri waktu debounce (jika ada) selesai, lalu tunggu UI stabil.
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pumpAndSettle();
  widgets.debugOnRebuildDirtyWidget = null;
  return counts;
}

void main() {
  for (final query in ['belanja 1', 'belanja']) {
    testWidgets('jumlah rebuild saat mengetik "$query"', (tester) async {
      final counts = await countRebuildsWhileTyping(tester, query);
      final sorted = counts.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      // ignore: avoid_print
      print('REBUILDS "$query" ${Map.fromEntries(sorted)}');
      // Batas regresi Minggu 11: halaman, AppBar, dan badge tidak boleh
      // ikut rebuild saat mengetik (sebelum optimasi: 1x per huruf).
      expect(counts['NotesPage'] ?? 0, 0);
      expect(counts['AppBar'] ?? 0, 0);
      expect(counts['Badge'] ?? 0, 0);
    });
  }
}
