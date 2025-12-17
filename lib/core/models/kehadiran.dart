class Kehadiran {
  final String id;
  final String santriId;
  final DateTime tanggal;
  final String status; // "H","S","I","A"

  Kehadiran({
    required this.id,
    required this.santriId,
    required this.tanggal,
    required this.status,
  });
}
