import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week3_navigation_state_management/providers/stats_provider.dart';

void main() {
  test('StatsNotifier dimulai dengan status loading', () {
    // Setup ProviderContainer
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Membaca statsProvider
    final asyncValue = container.read(statsProvider);

    // Secara default AsyncNotifierProvider dimulai dengan state loading sebelum async task pertama selesai
    expect(asyncValue.isLoading, true);
  });
}
