class PenilaianAkhlak {
  final String id;
  final String santriId;
  final int disiplin; // 1-4
  final int adab; // 1-4
  final int kebersihan; // 1-4
  final int kerjasama; // 1-4
  final String? catatan;

  PenilaianAkhlak({
    required this.id,
    required this.santriId,
    required this.disiplin,
    required this.adab,
    required this.kebersihan,
    required this.kerjasama,
    this.catatan,
  });
}
