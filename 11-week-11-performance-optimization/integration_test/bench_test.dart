// Micro-benchmark di perangkat (mode profile/AOT). Algoritma lama dan
// baru diukur di run yang SAMA dan berselang-seling (3 putaran), sehingga
// kondisi emulator memengaruhi keduanya secara setara.
//
//   flutter drive --profile --no-dds --driver=test_driver/perf_driver.dart //     --target=integration_test/bench_test.dart -d emulator-5554
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:week11_performance_optimization/data/repositories/note_repository.dart';
import 'package:week11_performance_optimization/domain/usecases/filter_notes_usecase.dart';

import 'seed.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('benchmark: search per ketikan dan query detail', (tester) async {
    await seedNotes();
    final repo = NoteRepository();
    final notes = await repo.fetchNotes();
    final id = notes[1000].id!;
    const queries = ['b', 'be', 'bel', 'bela', 'belan', 'belanj', 'belanja'];

    double timeIt(void Function() body, {int rounds = 30}) {
      final sw = Stopwatch()..start();
      for (var i = 0; i < rounds; i++) {
        body();
      }
      return sw.elapsedMicroseconds / rounds / 1000;
    }

    Future<double> timeAsync(Future<void> Function() body) async {
      final sw = Stopwatch()..start();
      for (var i = 0; i < 10; i++) {
        await body();
      }
      return sw.elapsedMicroseconds / 10 / 1000;
    }

    final result = <String, double>{};
    for (var round = 0; round < 3; round++) {
      // Lama: filterNotes memanggil toLowerCase() di setiap ketikan.
      result['search_lama_ms_per_ketikan_r$round'] =
          timeIt(() {
            for (final q in queries) {
              filterNotes(notes, q);
            }
          }) /
          queries.length;
      // Baru: indeks dibuat sekali, lalu hanya `contains`.
      result['search_index_build_ms_r$round'] = timeIt(
        () => SearchIndex(notes),
      );
      final index = SearchIndex(notes);
      result['search_baru_ms_per_ketikan_r$round'] =
          timeIt(() {
            for (final q in queries) {
              index.search(q);
            }
          }) /
          queries.length;
      // Detail lama: muat semua lalu firstWhere; baru: WHERE id = ?.
      result['detail_lama_ms_r$round'] = await timeAsync(() async {
        (await repo.fetchNotes()).firstWhere((n) => n.id == id);
      });
      result['detail_baru_ms_r$round'] = await timeAsync(() async {
        await repo.fetchNoteById(id);
      });
    }
    binding.reportData = {...?binding.reportData, 'benchmark': result};
  });
}
