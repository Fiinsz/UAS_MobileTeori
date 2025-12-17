class PenilaianTahfidz {
  final String id;
  final String santriId;
  final DateTime minggu;
  final String surah;
  final int ayatSetor;
  final int tajwid; // 0-100

  PenilaianTahfidz({
    required this.id,
    required this.santriId,
    required this.minggu,
    required this.surah,
    required this.ayatSetor,
    required this.tajwid,
  });
}
