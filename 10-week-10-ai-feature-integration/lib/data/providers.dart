import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'repositories/note_repository.dart';
import 'local/note.dart';
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

// Provider untuk data cache (posts)
final cachedPostsProvider = FutureProvider<List<CachedPost>>((ref) {
  return loadPostsCacheFirst();
});

final noteDetailProvider = FutureProvider.family<Note?, int>((ref, id) async {
  final repo = ref.watch(noteRepositoryProvider);
  final notes = await repo.fetchNotes();
  try {
    return notes.firstWhere((n) => n.id == id);
  } catch (e) {
    return null;
  }
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

final searchNotesUseCaseProvider = Provider<SearchNotesUseCase>((ref) {
  return const SearchNotesUseCase();
});

final filteredNotesProvider = Provider<AsyncValue<List<Note>>>((ref) {
  final notesAsync = ref.watch(notesProvider);
  final query = ref.watch(searchQueryProvider);
  final useCase = ref.watch(searchNotesUseCaseProvider);

  return notesAsync.whenData((notes) => useCase(notes, query));
});
