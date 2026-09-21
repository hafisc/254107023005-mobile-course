import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/providers.dart';

class NoteDetailPage extends ConsumerWidget {
  final int? id;
  const NoteDetailPage({super.key, this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (id == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('ID tidak valid')),
      );
    }

    final noteAsync = ref.watch(noteDetailProvider(id!));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Catatan')),
      body: noteAsync.when(
        data: (note) {
          if (note == null) {
            return const Center(child: Text('Catatan tidak ditemukan'));
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(note.title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),
                Text(note.body, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 16),
                const Divider(),
                Text('Diperbarui: ${note.updatedAt.toLocal().toString().split('.')[0]}'),
                Text('Status Sinkronisasi: ${note.dirty ? "Belum" : "Sudah"}'),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
