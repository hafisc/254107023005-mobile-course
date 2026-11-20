import 'dart:async';

import 'package:week12_testing_quality_assurance/data/local/note.dart';
import 'package:week12_testing_quality_assurance/data/repositories/note_repository.dart';

/// Repository palsu di memori. Perilakunya dikendalikan oleh test:
/// - [fetchError] / [addError] / [deleteError]: operasi tersebut gagal;
/// - [fetchGate] / [addGate]: operasi menunggu sampai gate diselesaikan,
///   untuk menguji tampilan loading tanpa jeda waktu tetap;
/// - [added], [deletedIds]: catatan pemanggilan untuk diperiksa test.
class FakeNoteRepository implements NoteRepository {
  FakeNoteRepository({
    List<Note> notes = const [],
    this.fetchError,
    this.addError,
    this.deleteError,
    this.fetchGate,
    this.addGate,
  }) : _notes = [...notes];

  final List<Note> _notes;
  Exception? fetchError;
  Exception? addError;
  Exception? deleteError;
  Completer<void>? fetchGate;
  Completer<void>? addGate;

  final List<({String title, String body})> added = [];
  final List<int> deletedIds = [];
  int fetchCount = 0;
  int _nextId = 1000;

  @override
  Future<List<Note>> fetchNotes() async {
    fetchCount++;
    if (fetchGate != null) await fetchGate!.future;
    if (fetchError != null) throw fetchError!;
    return List.unmodifiable(_notes);
  }

  @override
  Future<Note?> fetchNoteById(int id) async {
    for (final n in _notes) {
      if (n.id == id) return n;
    }
    return null;
  }

  @override
  Future<Note> addNote({required String title, String body = ''}) async {
    added.add((title: title, body: body));
    if (addGate != null) await addGate!.future;
    if (addError != null) throw addError!;
    final note = Note(
      id: _nextId++,
      title: title,
      body: body,
      updatedAt: DateTime(2026, 11, 20, 10),
      dirty: true,
    );
    _notes.insert(0, note);
    return note;
  }

  @override
  Future<void> deleteNote(int id) async {
    deletedIds.add(id);
    if (deleteError != null) throw deleteError!;
    _notes.removeWhere((n) => n.id == id);
  }

  @override
  Future<int> countDirty() async => _notes.where((n) => n.dirty).length;

  @override
  Future<void> markAllSynced() async {
    for (var i = 0; i < _notes.length; i++) {
      final n = _notes[i];
      _notes[i] = Note(
        id: n.id,
        title: n.title,
        body: n.body,
        updatedAt: n.updatedAt,
      );
    }
  }
}
