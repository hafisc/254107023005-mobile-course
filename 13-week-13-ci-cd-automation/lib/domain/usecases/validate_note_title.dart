/// Minggu 12: aturan judul catatan (pure Dart, mudah diuji unit).
const maxNoteTitleLength = 80;

/// Mengembalikan pesan error, atau `null` bila judul valid.
/// Spasi di awal/akhir diabaikan. Panjang dihitung per karakter Unicode
/// (`runes`), bukan per unit UTF-16, supaya emoji tidak dihitung dua.
String? validateNoteTitle(String? value) {
  final title = (value ?? '').trim();
  if (title.isEmpty) return 'Judul wajib diisi';
  if (title.runes.length > maxNoteTitleLength) {
    return 'Judul maksimal $maxNoteTitleLength karakter';
  }
  return null;
}
