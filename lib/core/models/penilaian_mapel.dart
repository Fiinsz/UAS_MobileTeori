class PenilaianMapel {
  final String id;
  final String santriId;
  final String mapel; // "Fiqh" | "Bahasa Arab"
  final int formatif; // 0-100
  final int sumatif; // 0-100

  PenilaianMapel({
    required this.id,
    required this.santriId,
    required this.mapel,
    required this.formatif,
    required this.sumatif,
  });
}
