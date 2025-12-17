class Santri {
  final String id;
  final String nis;
  final String nama;
  final String kamar;
  final int angkatan;

  const Santri({
    required this.id,
    required this.nis,
    required this.nama,
    required this.kamar,
    required this.angkatan,
  });

  factory Santri.fromMap(Map<String, dynamic> m) => Santri(
        id: m['id'] as String,
        nis: m['nis'] as String,
        nama: m['nama'] as String,
        kamar: m['kamar'] as String,
        angkatan: m['angkatan'] as int,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'nis': nis,
        'nama': nama,
        'kamar': kamar,
        'angkatan': angkatan,
      };
}
