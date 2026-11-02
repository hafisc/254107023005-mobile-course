import 'package:flutter_test/flutter_test.dart';
import 'package:week9_ai_assisted_development/data/local/note.dart';
import 'package:week9_ai_assisted_development/domain/usecases/filter_notes_usecase.dart';

void main() {
  group('Search & Filter Notes UseCase Unit Tests', () {
    final sampleNotes = [
      Note(
        id: 1,
        title: 'Daftar Belanja Bulanan',
        body: 'Susu, telur, beras, minyak goreng',
        updatedAt: DateTime(2026, 10, 1),
      ),
      Note(
        id: 2,
        title: 'Tugas Kuliah Pemrograman Mobile',
        body: 'Selesaikan Codelab Minggu 9 dan buat laporan ai-log.md',
        updatedAt: DateTime(2026, 10, 2),
      ),
      Note(
        id: 3,
        title: 'Rencana Belanja Elektronik',
        body: 'Beli kabel USB-C dan mouse bluetooth',
        updatedAt: DateTime(2026, 10, 3),
      ),
      Note(
        id: 4,
        title: 'Ide Liburan Akhir Semester',
        body: 'Camping di pegunungan bersama teman',
        updatedAt: DateTime(2026, 10, 4),
      ),
    ];

    test('filter abaikan huruf besar/kecil', () {
      final result = filterNotes(sampleNotes, 'belanja');
      expect(result, hasLength(2));
      expect(result.any((n) => n.id == 1), isTrue);
      expect(result.any((n) => n.id == 3), isTrue);
    });

    test('query tak cocok kembalikan kosong', () {
      final result = filterNotes(sampleNotes, 'zzz-tak-ada');
      expect(result, isEmpty);
    });

    test('query kosong kembalikan seluruh catatan', () {
      final resultEmpty = filterNotes(sampleNotes, '');
      final resultWhitespace = filterNotes(sampleNotes, '   ');
      expect(resultEmpty, hasLength(4));
      expect(resultWhitespace, hasLength(4));
    });

    test('query dengan spasi di awal dan akhir di-trim dengan benar', () {
      final result = filterNotes(sampleNotes, '  kuliah  ');
      expect(result, hasLength(1));
      expect(result.first.title, contains('Kuliah'));
    });

    test('filter dapat mencocokkan teks yang berada di dalam body catatan', () {
      final result = filterNotes(sampleNotes, 'kabel USB-C');
      expect(result, hasLength(1));
      expect(result.first.id, 3);
    });

    test('SearchNotesUseCase class mengeksekusi logika yang identik', () {
      const useCase = SearchNotesUseCase();
      final result = useCase(sampleNotes, 'belanja');
      expect(result, hasLength(2));
    });
  });
}
