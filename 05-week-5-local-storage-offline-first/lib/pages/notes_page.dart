import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/providers.dart';
import '../widgets/note_tile.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);
    final dirtyCountAsync = ref.watch(dirtyCountProvider);
    final dirtyCount = dirtyCountAsync.value ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Offline'),
        actions: [
          if (dirtyCount > 0)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Badge(
                  label: Text(dirtyCount.toString()),
                  child: const Icon(Icons.cloud_upload),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sinkronisasi...')),
              );
              await ref.read(notesProvider.notifier).syncData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.cloud_download),
            onPressed: () => context.go('/posts'),
            tooltip: 'Cached Posts',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(notesProvider);
          await ref.read(notesProvider.future);
        },
        child: notesAsync.when(
          data: (notes) {
            if (notes.isEmpty) {
              return const Center(child: Text('Belum ada catatan.'));
            }
            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return Dismissible(
                  key: ValueKey(note.id),
                  background: Container(color: Colors.red),
                  onDismissed: (_) {
                    if (note.id != null) {
                      ref.read(notesProvider.notifier).deleteNote(note.id!);
                    }
                  },
                  child: NoteTile(note: note),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(notesProvider.notifier).addNote(
            'Catatan Baru', 
            'Isi catatan dibuat pada ${DateTime.now().toLocal().toString().split('.')[0]}'
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
