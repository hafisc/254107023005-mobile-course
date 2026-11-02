# AI Prompt Challenge - Week 5

## Prompt yang Digunakan
```text
Aplikasi Flutter Offline Notes: CRUD catatan + preferensi tema.
Bandingkan SharedPreferences, Hive, sqflite (SQLite), dan Drift
untuk dua kebutuhan ini. Requirements:
- Kriteria: kompleksitas query, kebutuhan relasi, reaktivitas (stream),
  type-safety, ukuran boilerplate, dan kemudahan testing.
- Beri rekomendasi final: mana untuk preferensi, mana untuk catatan,
  beserta alasannya dalam 1 tabel.
- Tunjukkan skema tabel/kotak untuk 1000+ catatan.
Jelaskan trade-off setiap pilihan.
```

## AI Verification & Storage Comparison

### Perbandingan Penyimpanan (Storage)
| Kriteria | SharedPreferences | Hive (NoSQL) | sqflite (SQLite) | Drift (ORM) |
| --- | --- | --- | --- | --- |
| **Kompleksitas Query** | Sangat Rendah (Key-Value) | Rendah (Map-like) | Sedang - Tinggi (SQL) | Tinggi (Type-safe SQL) |
| **Kebutuhan Relasi** | Tidak Ada | Terbatas (Hive links) | Penuh (JOIN, Foreign Key) | Penuh (Relasi otomatis) |
| **Reaktivitas (Stream)** | Tidak Ada | Ya (listenable) | Tidak (manual via Riverpod) | Ya (Out-of-the-box Streams) |
| **Type-Safety** | Rendah (Cast manual) | Sedang (TypeAdapters) | Rendah (Map<String, dynamic>) | Sangat Tinggi (Generated classes) |
| **Ukuran Boilerplate** | Sangat Kecil | Sedang (Build_runner untuk Adapter) | Sedang (SQL string mentah) | Sangat Besar (Build_runner, file .g.dart) |
| **Kemudahan Testing** | Sangat Mudah (Map/Mock) | Mudah | Sedikit Rumit (Butuh library mock) | Mudah (In-memory Web/Test DB) |

### Keputusan Final (Sesuai AI Challenge Verification)
**1. Preferensi (Tema & Waktu Terakhir Dibuka): SharedPreferences**
- **Alasan:** Data hanya berupa primitif statis (`bool` dan `String`). Membuka database rasional hanya untuk membaca status "gelap/terang" adalah pemborosan resource (overkill). SharedPreferences secara natural didesain untuk preferensi UI berskala sangat kecil.

**2. Catatan (Notes): sqflite (SQLite)**
- **Alasan Penolakan SharedPreferences:** Menyimpan daftar 1000 catatan sebagai _String JSON_ tunggal dalam SharedPreferences adalah ide yang sangat buruk (membutuhkan serialisasi/deserialisasi terus-menerus dan memakan banyak memori).
- **Alasan Penolakan Drift:** Meskipun Drift menawarkan `Stream` yang canggih dan *Type-Safety*, ukuran aplikasi kita masih berupa purwarupa _Mini Project_. *Boilerplate* Drift (menggunakan `build_runner`) dirasa terlalu berlebihan saat ini.
- **Alasan Pemilihan SQLite:** `sqflite` paling umum di industri untuk manipulasi *offline-first* dengan relasi dan dukungan asinkronus (*dirty flag*, *updated_at* sorting) tanpa *overhead* code-generation yang masif.

**3. Skema Data (SQLite)**
```sql
CREATE TABLE notes(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL,
  dirty INTEGER NOT NULL DEFAULT 0
)
```
