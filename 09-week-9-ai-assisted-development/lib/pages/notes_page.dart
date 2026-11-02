import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/providers.dart';
import '../widgets/empty_state.dart';
import '../widgets/note_tile.dart';

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotesAsync = ref.watch(filteredNotesProvider);
    final searchQuery = ref.watch(searchQueryProvider);
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
            tooltip: 'Sinkronisasi',
            onPressed: () async {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Sinkronisasi...')));
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
            tooltip: 'Pengaturan',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBox(context, searchQuery),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(notesProvider);
                await ref.read(notesProvider.future);
              },
              child: filteredNotesAsync.when(
                data: (notes) {
                  if (notes.isEmpty) {
                    if (searchQuery.isNotEmpty) {
                      return EmptyStateWidget(
                        message:
                            'Tidak ada catatan yang cocok dengan "$searchQuery"',
                        icon: Icons.search_off_rounded,
                        actionLabel: 'Hapus Pencarian',
                        onAction: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).clear();
                        },
                      );
                    }
                    return const EmptyStateWidget(
                      message:
                          'Belum ada catatan.\nTekan tombol + untuk membuat catatan baru.',
                      icon: Icons.note_add_outlined,
                    );
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
                            ref
                                .read(notesProvider.notifier)
                                .deleteNote(note.id!);
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref
              .read(notesProvider.notifier)
              .addNote(
                'Catatan Baru',
                'Isi catatan dibuat pada ${DateTime.now().toLocal().toString().split('.')[0]}',
              );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBox(BuildContext context, String query) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari catatan berdasarkan judul atau isi...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(searchQueryProvider.notifier).clear();
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onChanged: (value) {
          ref.read(searchQueryProvider.notifier).updateQuery(value);
        },
      ),
    );
  }
}
