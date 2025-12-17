import 'dart:math';

class Calculations {
  static int computeTahfidz({required int setor, required int target, required int tajwid}) {
    if (target <= 0) return 0;
    final capaian = min(100, (setor / target) * 100);
    final value = 0.5 * capaian + 0.5 * tajwid;
    return value.round();
  }

  static int computeMapel({required int formatif, required int sumatif}) {
    final value = 0.4 * formatif + 0.6 * sumatif;
    return value.round();
  }

  static int computeAkhlak({required int disiplin, required int adab, required int kebersihan, required int kerjasama}) {
    final avg = (disiplin + adab + kebersihan + kerjasama) / 4.0;
    final value = (avg / 4.0) * 100.0;
    return value.round();
  }

  static int computeKehadiran({required int h, required int s, required int i, required int a}) {
    final total = h + s + i + a;
    if (total == 0) return 0;
    final hadirPercent = (h / total) * 100.0;
    return hadirPercent.round();
  }

  static int computeFinal({
    required int tahfidz,
    required int fiqh,
    required int bahasaArab,
    required int akhlak,
    required int kehadiran,
    Map<String, double>? bobot,
  }) {
    final defaultBobot = {
      'tahfidz': 0.30,
      'fiqh': 0.20,
      'bahasaArab': 0.20,
      'akhlak': 0.20,
      'kehadiran': 0.10,
    };
    final w = {...defaultBobot, if (bobot != null) ...bobot};

    final value = w['tahfidz']! * tahfidz + w['fiqh']! * fiqh + w['bahasaArab']! * bahasaArab + w['akhlak']! * akhlak + w['kehadiran']! * kehadiran;
    return value.round();
  }

  static String predikatFromScore(int nilai) {
    if (nilai >= 85) return 'A';
    if (nilai >= 75) return 'B';
    if (nilai >= 65) return 'C';
    return 'D';
  }
}
