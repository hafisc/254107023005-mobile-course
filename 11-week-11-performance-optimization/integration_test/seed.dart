import 'package:week11_performance_optimization/data/local/db.dart';

/// Data uji yang sama untuk semua skenario profiling.
const seedCount = 2000;

Future<void> seedNotes() async {
  final db = await openNotesDb();
  await db.delete('notes');
  final batch = db.batch();
  final now = DateTime(2026, 11, 18);
  for (var i = 0; i < seedCount; i++) {
    batch.insert('notes', {
      'title': i % 10 == 0 ? 'Belanja minggu $i' : 'Catatan nomor $i',
      'body': 'Isi catatan ke-$i untuk uji performa daftar dan pencarian.',
      'updated_at': now.subtract(Duration(minutes: i)).toIso8601String(),
      'dirty': i.isEven ? 1 : 0,
    });
  }
  await batch.commit(noResult: true);
}
