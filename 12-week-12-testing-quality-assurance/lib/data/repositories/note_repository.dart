import 'package:sqflite/sqflite.dart';
import '../local/db.dart';
import '../local/note.dart';

/// Minggu 12: kontrak sumber data catatan. UI dan provider hanya bergantung
/// pada interface ini, sehingga test bisa memakai fake (sukses/error) tanpa
/// SQLite.
abstract interface class NoteRepository {
  Future<List<Note>> fetchNotes();
  Future<Note?> fetchNoteById(int id);
  Future<Note> addNote({required String title, String body = ''});
  Future<void> deleteNote(int id);
  Future<int> countDirty();
  Future<void> markAllSynced();
}

class SqliteNoteRepository implements NoteRepository {
  SqliteNoteRepository({Future<Database> Function()? openDb})
    : _openDb = openDb ?? openNotesDb;

  final Future<Database> Function() _openDb;

  @override
  Future<List<Note>> fetchNotes() async {
    final db = await _openDb();
    final rows = await db.query('notes', orderBy: 'updated_at DESC');
    return rows.map(Note.fromMap).toList();
  }

  /// Minggu 11: halaman detail hanya butuh 1 baris.
  @override
  Future<Note?> fetchNoteById(int id) async {
    final db = await _openDb();
    final rows = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Note.fromMap(rows.first);
  }

  @override
  Future<Note> addNote({required String title, String body = ''}) async {
    final db = await _openDb();
    final note = Note(
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      dirty: true,
    );
    final id = await db.insert('notes', note.toMap());
    return Note(
      id: id,
      title: note.title,
      body: note.body,
      updatedAt: note.updatedAt,
      dirty: true,
    );
  }

  @override
  Future<void> deleteNote(int id) async {
    final db = await _openDb();
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<int> countDirty() async {
    final db = await _openDb();
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM notes WHERE dirty = 1',
    );
    return ((rows.first['c'] as num?)?.toInt() ?? 0);
  }

  @override
  Future<void> markAllSynced() async {
    final db = await _openDb();
    await db.update('notes', {'dirty': 0}, where: 'dirty = 1');
  }
}
