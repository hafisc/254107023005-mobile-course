import 'package:flutter_test/flutter_test.dart';
import 'package:week11_performance_optimization/domain/usecases/redact_pii.dart';

void main() {
  group('redactPii', () {
    test('menyamarkan email', () {
      expect(redactPii('kirim ke budi.s@mail.com ya'), 'kirim ke [EMAIL] ya');
    });

    test('menyamarkan NIK 16 digit, bukan sebagai nomor HP', () {
      expect(redactPii('NIK saya 3573012345678901'), 'NIK saya [NIK]');
    });

    test('menyamarkan nomor HP format 08, +62, dan bersekat', () {
      expect(redactPii('hubungi 081234567890'), 'hubungi [TELEPON]');
      expect(redactPii('wa +6281234567890'), 'wa [TELEPON]');
      expect(redactPii('telp 0812-3456-7890'), 'telp [TELEPON]');
    });

    test('teks biasa dan angka pendek tidak diubah', () {
      const text = 'Rapat jam 10 di ruang 301, bawa 2 laptop';
      expect(redactPii(text), text);
    });
  });
}
