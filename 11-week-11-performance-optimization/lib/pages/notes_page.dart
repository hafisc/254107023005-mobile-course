import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/providers.dart';
import '../widgets/empty_state.dart';
import '../widgets/note_tile.dart';

/// Minggu 11: halaman tidak lagi `watch` provider apa pun.
/// Sebelumnya seluruh halaman (AppBar, badge, list) rebuild di setiap
/// ketikan search; kini hanya widget kecil yang datanya berubah.
class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: _NotesAppBar(),
      body: Column(
        children: [
          SearchBox(),
          Expanded(child: NotesList()),
        ],
      ),
      floatingActionButton: _AddNoteButton(),
    );
  }
}

class _NotesAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _NotesAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Catatan Offline'),
      actions: [
        const DirtyBadge(),
        IconButton(
          icon: const Icon(Icons.smart_toy_outlined),
          onPressed: () => context.go('/chat'),
          tooltip: 'Asisten AI',
        ),
        const _SyncButton(),
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
    );
  }
}

/// Satu-satunya widget yang bergantung pada jumlah catatan belum sinkron.
class DirtyBadge extends ConsumerWidget {
  const DirtyBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // select: rebuild hanya bila angkanya berubah, bukan tiap status async.
    final count = ref.watch(dirtyCountProvider.select((a) => a.value ?? 0));
    if (count == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Badge(
          label: Text('$count'),
          child: const Icon(Icons.cloud_upload),
        ),
      ),
    );
  }
}

class _SyncButton extends ConsumerWidget {
  const _SyncButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.sync),
      tooltip: 'Sinkronisasi',
      onPressed: () async {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sinkronisasi...')));
        await ref.read(notesProvider.notifier).syncData();
      },
    );
  }
}

class _AddNoteButton extends ConsumerWidget {
  const _AddNoteButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () => ref
          .read(notesProvider.notifier)
          .addNote(
            'Catatan Baru',
            'Isi catatan dibuat pada ${DateTime.now().toLocal().toString().split('.')[0]}',
          ),
      child: const Icon(Icons.add),
    );
  }
}

const searchDebounce = Duration(milliseconds: 250);

/// Kolom search memegang controller-nya sendiri dan menunda update query
/// [searchDebounce] setelah ketikan terakhir, sehingga filter 2000 catatan
/// tidak dijalankan ulang di setiap huruf.
class SearchBox extends ConsumerStatefulWidget {
  const SearchBox({super.key});

  @override
  ConsumerState<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends ConsumerState<SearchBox> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    // Timer wajib dibatalkan: bila tidak, callback berjalan setelah widget
    // dibuang dan memakai `ref` yang sudah tidak valid.
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(searchDebounce, () {
      ref.read(searchQueryProvider.notifier).updateQuery(value);
    });
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    ref.read(searchQueryProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    // Tombol "Hapus Pencarian" di empty state mengosongkan provider;
    // samakan teks di kolom.
    ref.listen(searchQueryProvider, (_, next) {
      if (next.isEmpty && _controller.text.isNotEmpty) _controller.clear();
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _controller,
        onChanged: _onChanged,
        decoration: InputDecoration(
          hintText: 'Cari catatan berdasarkan judul atau isi...',
          prefixIcon: const Icon(Icons.search),
          // Hanya ikon ini yang rebuild saat teks berubah.
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) => value.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(icon: const Icon(Icons.clear), onPressed: _clear),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}

class NotesList extends ConsumerWidget {
  const NotesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredNotesAsync = ref.watch(filteredNotesProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(notesProvider);
        await ref.read(notesProvider.future);
      },
      child: filteredNotesAsync.when(
        data: (notes) {
          if (notes.isEmpty) {
            if (searchQuery.isNotEmpty) {
              return EmptyStateWidget(
                message: 'Tidak ada catatan yang cocok dengan "$searchQuery"',
                icon: Icons.search_off_rounded,
                actionLabel: 'Hapus Pencarian',
                onAction: ref.read(searchQueryProvider.notifier).clear,
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
                background: const ColoredBox(color: Colors.red),
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
    );
  }
}
