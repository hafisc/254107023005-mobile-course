final _email = RegExp(r'[\w.+-]+@[\w-]+\.[\w.-]+');
// NIK: tepat 16 digit.
final _nik = RegExp(r'\b\d{16}\b');
// Nomor HP Indonesia: 08xx / +628xx / 628xx, boleh dipisah spasi atau strip.
final _phone = RegExp(r'(\+62|62|0)8[\d\s-]{7,13}\d');

/// Menyamarkan data pribadi sebelum teks dikirim ke AI API.
/// Urutan penting: NIK dulu, supaya 16 digit tidak terbaca sebagai nomor HP.
String redactPii(String input) {
  return input
      .replaceAll(_email, '[EMAIL]')
      .replaceAll(_nik, '[NIK]')
      .replaceAll(_phone, '[TELEPON]');
}
