import 'package:flutter_test/flutter_test.dart';
import 'package:week12_testing_quality_assurance/data/local/note.dart';
import 'package:week12_testing_quality_assurance/domain/usecases/filter_notes_usecase.dart';

void main() {
  final notes = [
    for (var i = 0; i < 300; i++)
      Note(
        id: i,
        title: i % 7 == 0 ? 'Belanja Minggu $i' : 'Catatan $i',
        body: i % 5 == 0 ? 'beli SAYUR dan buah' : 'isi biasa $i',
        updatedAt: DateTime(2026),
      ),
  ];
  final index = SearchIndex(notes);

  for (final q in [
    '',
    '   ',
    'belanja',
    'BELANJA 1',
    ' sayur ',
    'catatan 29',
    'zzz-tak-ada',
    'minggu 14',
  ]) {
    test('SearchIndex sama persis dengan filterNotes untuk "$q"', () {
      expect(index.search(q), filterNotes(notes, q));
    });
  }

  test('query kosong mengembalikan list asli tanpa salinan', () {
    expect(identical(index.search(''), notes), isTrue);
  });
}
