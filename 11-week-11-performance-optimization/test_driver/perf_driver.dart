import 'dart:convert';
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart' as driver;
import 'package:integration_test/integration_test_driver.dart';

/// Menulis ringkasan timeline tiap skenario ke folder build/.
Future<void> main() {
  return integrationDriver(
    responseDataCallback: (data) async {
      if (data == null) return;
      for (final entry in data.entries) {
        if (entry.key == 'benchmark') {
          await File('build/benchmark.json').writeAsString(
            const JsonEncoder.withIndent('  ').convert(entry.value),
          );
          continue;
        }
        final timeline = driver.Timeline.fromJson(
          entry.value as Map<String, dynamic>,
        );
        final summary = driver.TimelineSummary.summarize(timeline);
        await summary.writeTimelineToFile(
          entry.key,
          pretty: true,
          includeSummary: true,
        );
      }
    },
  );
}
