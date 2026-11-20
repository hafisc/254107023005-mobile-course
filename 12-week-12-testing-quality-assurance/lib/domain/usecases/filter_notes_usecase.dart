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

/// Minggu 11: teks pencarian (judul + isi, huruf kecil) dihitung SEKALI
/// tiap daftar catatan berubah. Versi lama memanggil `toLowerCase()` dua
/// kali per catatan di setiap ketikan (2000 catatan = 4000 string baru per
/// huruf), yang memicu garbage collection saat mengetik.
class SearchIndex {
  SearchIndex(this.notes)
    : _haystacks = [
        for (final n in notes) '${n.title}\n${n.body}'.toLowerCase(),
      ];

  final List<Note> notes;
  final List<String> _haystacks;

  /// Hasil identik dengan [filterNotes] (diuji di search_index_test.dart).
  List<Note> search(String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return notes;
    return [
      for (var i = 0; i < notes.length; i++)
        if (_haystacks[i].contains(trimmed)) notes[i],
    ];
  }
}
