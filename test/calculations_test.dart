import 'package:flutter_test/flutter_test.dart';
import 'package:e_pesantren/core/services/calculations.dart';

void main() {
  group('Calculations', () {
    test('Tahfidz sample values', () {
      // s1: target 50, setor 60, tajwid 85 -> 93
      final s1 = Calculations.computeTahfidz(setor: 60, target: 50, tajwid: 85);
      expect(s1, 93);

      // s2: target 50, setor 30, tajwid 78 -> 69
      final s2 = Calculations.computeTahfidz(setor: 30, target: 50, tajwid: 78);
      expect(s2, 69);
    });

    test('Mapel calculation', () {
      // s1 fiqh: 80 & 90 -> 86
      final f1 = Calculations.computeMapel(formatif: 80, sumatif: 90);
      expect(f1, 86);

      // s2 fiqh: 70 & 75 -> 73
      final f2 = Calculations.computeMapel(formatif: 70, sumatif: 75);
      expect(f2, 73);
    });

    test('Akhlak conversion', () {
      // s1: [4,4,3,4] avg=3.75 -> 94
      final a1 = Calculations.computeAkhlak(disiplin: 4, adab: 4, kebersihan: 3, kerjasama: 4);
      expect(a1, 94);

      // s2: [3,3,3,2] avg=2.75 -> 69
      final a2 = Calculations.computeAkhlak(disiplin: 3, adab: 3, kebersihan: 3, kerjasama: 2);
      expect(a2, 69);
    });

    test('Kehadiran rekap', () {
      // s1: H=18,S=1,I=1,A=0 -> 90
      final k1 = Calculations.computeKehadiran(h: 18, s: 1, i: 1, a: 0);
      expect(k1, 90);

      // s2: H=14,S=2,I=1,A=3 -> 70
      final k2 = Calculations.computeKehadiran(h: 14, s: 2, i: 1, a: 3);
      expect(k2, 70);
    });

    test('Final score and predikat', () {
      // s1 combine
      final tahfidz1 = 93;
      final fiqh1 = 86;
      final bahasa1 = 78;
      final akhlak1 = 94;
      final kehadiran1 = 90;
      final final1 = Calculations.computeFinal(
        tahfidz: tahfidz1,
        fiqh: fiqh1,
        bahasaArab: bahasa1,
        akhlak: akhlak1,
        kehadiran: kehadiran1,
      );
      expect(final1, 89);
      expect(Calculations.predikatFromScore(final1), 'A');

      // s2 combine
      final tahfidz2 = 69;
      final fiqh2 = 73;
      final bahasa2 = 63;
      final akhlak2 = 69;
      final kehadiran2 = 70;
      final final2 = Calculations.computeFinal(
        tahfidz: tahfidz2,
        fiqh: fiqh2,
        bahasaArab: bahasa2,
        akhlak: akhlak2,
        kehadiran: kehadiran2,
      );
      expect(final2, 69);
      expect(Calculations.predikatFromScore(final2), 'C');
    });
  });
}
