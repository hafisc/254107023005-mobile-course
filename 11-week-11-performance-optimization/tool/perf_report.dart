// Ringkas hasil `flutter drive --profile` menjadi tabel Markdown.
//
//   dart run tool/perf_report.dart docs/profiling/before/run1 docs/profiling/after/run1
//
// Tiap folder berisi <skenario>.timeline_summary.json hasil test_driver.
import 'dart:convert';
import 'dart:io';

const scenarios = ['scroll', 'search', 'detail'];

String _ms(Object? v) => v == null ? '-' : (v as num).toStringAsFixed(2);

void main(List<String> dirs) {
  if (dirs.isEmpty) dirs = ['build'];
  stdout.writeln(
    '| Run | Skenario | Frame | Build rata2 (ms) | Build p90 | Build terburuk '
    '| Jank build (>16ms) | Raster rata2 (ms) | Jank raster |',
  );
  stdout.writeln('|---|---|---|---|---|---|---|---|---|');
  for (final dir in dirs) {
    for (final s in scenarios) {
      final file = File('$dir/$s.timeline_summary.json');
      if (!file.existsSync()) continue;
      final j = jsonDecode(file.readAsStringSync()) as Map;
      stdout.writeln(
        '| $dir | $s | ${j['frame_count']} '
        '| ${_ms(j['average_frame_build_time_millis'])} '
        '| ${_ms(j['90th_percentile_frame_build_time_millis'])} '
        '| ${_ms(j['worst_frame_build_time_millis'])} '
        '| ${j['missed_frame_build_budget_count']} '
        '| ${_ms(j['average_frame_rasterizer_time_millis'])} '
        '| ${j['missed_frame_rasterizer_budget_count']} |',
      );
    }
  }
}
