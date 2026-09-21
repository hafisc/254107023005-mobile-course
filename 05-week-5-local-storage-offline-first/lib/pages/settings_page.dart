import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/prefs.dart';

final prefsRepositoryProvider = Provider((ref) => PrefsRepository());

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() =>
      ref.watch(prefsRepositoryProvider).getDarkMode();

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
      return next;
    });
  }
}

final darkModeProvider =
    AsyncNotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);

final lastOpenedProvider = FutureProvider<String?>((ref) async {
  return ref.watch(prefsRepositoryProvider).getLastOpened();
});

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkAsync = ref.watch(darkModeProvider);
    final lastOpenedAsync = ref.watch(lastOpenedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          isDarkAsync.when(
            data: (isDark) => SwitchListTile(
              title: const Text('Tema Gelap'),
              value: isDark,
              onChanged: (val) {
                ref.read(darkModeProvider.notifier).toggle();
              },
            ),
            loading: () => const ListTile(
              title: Text('Tema Gelap'),
              trailing: CircularProgressIndicator(),
            ),
            error: (err, stack) => ListTile(
              title: const Text('Tema Gelap'),
              subtitle: Text(err.toString()),
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Terakhir Dibuka'),
            subtitle: lastOpenedAsync.when(
              data: (dateString) {
                if (dateString == null) return const Text('Belum pernah dibuka');
                final date = DateTime.tryParse(dateString);
                if (date == null) return const Text('Format tanggal salah');
                // Format sederhana tanpa library intl
                final formatted = date.toLocal().toString().split('.')[0];
                return Text(formatted);
              },
              loading: () => const Text('Memuat...'),
              error: (err, stack) => Text('Error: $err'),
            ),
          ),
        ],
      ),
    );
  }
}
