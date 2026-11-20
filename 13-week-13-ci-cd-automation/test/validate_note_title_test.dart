import 'package:flutter_test/flutter_test.dart';
import 'package:week13_ci_cd_automation/domain/usecases/validate_note_title.dart';

void main() {
  group('validateNoteTitle', () {
    test('menerima judul yang berisi teks', () {
      expect(validateNoteTitle('Belanja bulanan'), isNull);
    });

    test('menolak null, teks kosong, dan hanya spasi/tab/baris baru', () {
      for (final value in [null, '', '   ', '\t', ' \n ']) {
        expect(
          validateNoteTitle(value),
          'Judul wajib diisi',
          reason: 'input: ${value == null ? 'null' : '"$value"'}',
        );
      }
    });

    test('spasi di awal/akhir diabaikan, teks di tengah tetap valid', () {
      expect(validateNoteTitle('  Rapat PBL  '), isNull);
    });

    group('batas panjang $maxNoteTitleLength karakter', () {
      test('tepat $maxNoteTitleLength karakter diterima', () {
        expect(validateNoteTitle('a' * maxNoteTitleLength), isNull);
      });

      test('${maxNoteTitleLength + 1} karakter ditolak', () {
        expect(
          validateNoteTitle('a' * (maxNoteTitleLength + 1)),
          'Judul maksimal $maxNoteTitleLength karakter',
        );
      });

      test('spasi tambahan di luar batas tidak ikut dihitung', () {
        expect(validateNoteTitle('  ${'a' * maxNoteTitleLength}  '), isNull);
      });

      test('emoji dihitung 1 karakter, bukan 2 unit UTF-16', () {
        // '📝' = 2 unit UTF-16. Bila dihitung dengan .length, 80 emoji
        // = 160 dan salah ditolak.
        expect(validateNoteTitle('📝' * maxNoteTitleLength), isNull);
        expect(validateNoteTitle('📝' * (maxNoteTitleLength + 1)), isNotNull);
      });
    });
  });
}
