import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'repositories/note_repository.dart';
import 'local/note.dart';
import 'posts_repository.dart';
import 'sync.dart';
import '../domain/usecases/filter_notes_usecase.dart';

final noteRepositoryProvider = Provider((ref) => NoteRepository());

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() async {
    final repo = ref.watch(noteRepositoryProvider);
    return await repo.fetchNotes();
  }

  Future<void> addNote(String title, String body) async {
    final repo = ref.read(noteRepositoryProvider);
    await repo.addNote(title: title, body: body);
    ref.invalidateSelf();
  }

  Future<void> deleteNote(int id) async {
    final repo = ref.read(noteRepositoryProvider);
    await repo.deleteNote(id);
    ref.invalidateSelf();
  }

  Future<void> syncData() async {
    final repo = ref.read(noteRepositoryProvider);
    await syncNotes(repo);
    ref.invalidateSelf();
  }
}

final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
);

// Provider untuk menghitung jumlah dirty note.
// Ini akan dipanggil ulang setiap notes berubah karena kita watch notesProvider.
final dirtyCountProvider = FutureProvider<int>((ref) {
  ref.watch(notesProvider);
  return ref.watch(noteRepositoryProvider).countDirty();
});

final postsRepositoryProvider = Provider((ref) => PostsRepository());

/// Stale-while-revalidate: tampilkan cache segera, ambil data segar di
/// background, lalu perbarui UI. Versi lama mengambil data segar tetapi
/// tidak pernah memberi tahu UI, dan memanggil jaringan tiap halaman dibuka.
class PostsNotifier extends AsyncNotifier<List<CachedPost>> {
  @override
  Future<List<CachedPost>> build() async {
    final repo = ref.watch(postsRepositoryProvider);
    final cached = await repo.readCache();
    if (cached.isEmpty) {
      // Belum ada cache: tunggu jaringan agar layar tidak kosong.
      return await repo.refresh() ?? cached;
    }
    _revalidate(repo);
    return cached;
  }

  Future<void> _revalidate(PostsRepository repo, {bool force = false}) async {
    final fresh = await repo.refresh(force: force);
    if (fresh != null && ref.mounted) state = AsyncData(fresh);
  }

  /// Tombol refresh: paksa ambil data segar, data lama tetap tampil.
  Future<void> refresh() =>
      _revalidate(ref.read(postsRepositoryProvider), force: true);
}

final postsProvider = AsyncNotifierProvider<PostsNotifier, List<CachedPost>>(
  PostsNotifier.new,
);

final noteDetailProvider = FutureProvider.family<Note?, int>((ref, id) {
  return ref.watch(noteRepositoryProvider).fetchNoteById(id);
});

// Search & Filter Providers (Refactored Clean Architecture with Riverpod 3)
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String value) => state = value;
  void clear() => state = '';
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

/// Indeks dibangun ulang hanya saat daftar catatan berubah, bukan per ketikan.
final searchIndexProvider = Provider<AsyncValue<SearchIndex>>((ref) {
  return ref.watch(notesProvider).whenData(SearchIndex.new);
});

final filteredNotesProvider = Provider<AsyncValue<List<Note>>>((ref) {
  final indexAsync = ref.watch(searchIndexProvider);
  final query = ref.watch(searchQueryProvider);
  return indexAsync.whenData((index) => index.search(query));
});
