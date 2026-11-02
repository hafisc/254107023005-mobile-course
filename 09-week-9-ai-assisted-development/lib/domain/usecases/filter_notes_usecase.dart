import '../../data/local/note.dart';

/// Pure Dart function to filter notes by title or body.
/// Satisfies the Domain layer sterility rule: no Flutter, Dio, or SQLite imports.
List<Note> filterNotes(List<Note> notes, String query) {
  final trimmed = query.trim().toLowerCase();
  if (trimmed.isEmpty) return notes;

  return notes.where((note) {
    final titleMatch = note.title.toLowerCase().contains(trimmed);
    final bodyMatch = note.body.toLowerCase().contains(trimmed);
    return titleMatch || bodyMatch;
  }).toList();
}

/// UseCase class adhering to Clean Architecture single responsibility principle.
class SearchNotesUseCase {
  const SearchNotesUseCase();

  List<Note> call(List<Note> notes, String query) {
    return filterNotes(notes, query);
  }
}
