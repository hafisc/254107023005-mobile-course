import 'dart:async';

import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

/// Mengaktifkan leak tracker untuk test di folder ini. Tanpa `enable()`,
/// parameter `experimentalLeakTesting` di testWidgets tidak melakukan apa pun
/// (terbukti lewat kontrol negatif, lihat docs/performance-report.md).
FutureOr<void> testExecutable(FutureOr<void> Function() testMain) async {
  LeakTesting.enable();
  LeakTesting.settings = LeakTesting.settings.withIgnored(
    createdByTestHelpers: true,
  );
  await testMain();
}
