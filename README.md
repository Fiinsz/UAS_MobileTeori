# e_pesantren

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Template additions (core)

- `lib/core/models/*` : simple models (`Santri`, `PenilaianTahfidz`, `PenilaianMapel`, `PenilaianAkhlak`, `Kehadiran`).
- `lib/core/services/calculations.dart` : contains pure functions implementing perhitungan nilai (Tahfidz, Mapel, Akhlak, Kehadiran, Nilai Akhir, Predikat).

## Tests

- Unit tests for perhitungan berada di `test/calculations_test.dart`.
- Run tests with:

```powershell
flutter test test/calculations_test.dart
```

Jika ingin, saya bisa melanjutkan dengan menambahkan UI wireframes (Login, Daftar Santri, Detail Santri + tab), local DB layer (drift), dan mekanisme sinkronisasi offline-first.

## Credentials (mock)

Gunakan akun mock berikut saat mencoba aplikasi (login di halaman `Login`):

- **Admin**: `admin@pesantren.test` / `admin123`
- **Ustadz**: `ustadz@pesantren.test` / `ustadz123`
- **Wali Santri**: `wali@pesantren.test` / `wali123`

Catatan: ini hanya contoh akun untuk pengujian lokal; jangan gunakan kredensial nyata.
