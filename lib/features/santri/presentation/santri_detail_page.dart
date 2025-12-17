import 'package:flutter/material.dart';
import '../../../core/services/calculations.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/models/santri.dart';
import '../providers/santri_provider.dart';
import 'dart:convert';

class SantriDetailPage extends StatelessWidget {
  const SantriDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final id = args?['id'] as String?;
    if (id == null) return const Scaffold(body: Center(child: Text('Santri ID tidak ditemukan')));

    final fallbackScores = sampleScoresFor(id);

    Widget buildFrom(Santri santri, Map<String, dynamic> scores, BuildContext context) {
      final tahf = scores['tahfidz'] as Map<String, dynamic>;
      final mfiqh = scores['fiqh'] as Map<String, dynamic>;
      final mbahasa = scores['bahasa'] as Map<String, dynamic>;
      final akh = scores['akhlak'] as Map<String, dynamic>;
      final keh = scores['kehadiran'] as Map<String, dynamic>;

      final tahfScore = Calculations.computeTahfidz(setor: tahf['setor'], target: tahf['target'], tajwid: tahf['tajwid']);
      final fiqhScore = Calculations.computeMapel(formatif: mfiqh['formatif'], sumatif: mfiqh['sumatif']);
      final bahasaScore = Calculations.computeMapel(formatif: mbahasa['formatif'], sumatif: mbahasa['sumatif']);
      final akhlakScore = Calculations.computeAkhlak(disiplin: akh['disiplin'], adab: akh['adab'], kebersihan: akh['kebersihan'], kerjasama: akh['kerjasama']);
      final kehadiranScore = Calculations.computeKehadiran(h: keh['h'], s: keh['s'], i: keh['i'], a: keh['a']);
      final finalScore = Calculations.computeFinal(tahfidz: tahfScore, fiqh: fiqhScore, bahasaArab: bahasaScore, akhlak: akhlakScore, kehadiran: kehadiranScore);

      return DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text(santri.nama),
            bottom: const TabBar(tabs: [Tab(text: 'Penilaian'), Tab(text: 'Kehadiran'), Tab(text: 'Grafik'), Tab(text: 'Rapor')]),
          ),
          body: TabBarView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Tahfidz: $tahfScore', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('Fiqh: $fiqhScore', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      Text('Bahasa Arab: $bahasaScore', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      Text('Akhlak: $akhlakScore', style: Theme.of(context).textTheme.bodyMedium),
                    ]),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Hadir: ${keh['h']}', style: Theme.of(context).textTheme.bodyMedium),
                      Text('Sakit: ${keh['s']}', style: Theme.of(context).textTheme.bodyMedium),
                      Text('Izin: ${keh['i']}', style: Theme.of(context).textTheme.bodyMedium),
                      Text('Alpa: ${keh['a']}', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      Text('Kehadiran %: $kehadiranScore', style: Theme.of(context).textTheme.titleMedium),
                    ]),
                  ),
                ),
              ),
              const Center(child: Text('Grafik (placeholder)')),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Nilai Akhir: $finalScore', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text('Predikat: ${Calculations.predikatFromScore(finalScore)}', style: Theme.of(context).textTheme.titleMedium),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Map<String, dynamic> _normalizeFirestorePenilaian(Map<String, dynamic> doc) {
      // Accept both our app's sample structure and console-entered flat fields.
      // Expected normalized keys: tahfidz, fiqh, bahasa, akhlak, kehadiran
      Map<String, dynamic> tahfidz;
      Map<String, dynamic> fiqh;
      Map<String, dynamic> bahasa;
      Map<String, dynamic> akhlak;
      Map<String, dynamic> kehadiran;

      // Tahfidz may be a number total; if so, map to components roughly
      if (doc['tahfidz'] is Map<String, dynamic>) {
        tahfidz = Map<String, dynamic>.from(doc['tahfidz']);
      } else {
        final num v = (doc['tahfidz'] ?? 0) as num;
        tahfidz = {'setor': v, 'target': 100, 'tajwid': 80};
      }

      // Mapel can be an object or a JSON string as seen in console input
      Map<String, dynamic> mapel;
      if (doc['mapel'] is String) {
        try {
          mapel = Map<String, dynamic>.from(json.decode(doc['mapel'] as String));
        } catch (_) {
          mapel = {'fiqih': 80, 'bahasaArab': 80};
        }
      } else if (doc['mapel'] is Map<String, dynamic>) {
        mapel = Map<String, dynamic>.from(doc['mapel']);
      } else {
        mapel = {'fiqih': 80, 'bahasaArab': 80};
      }
      fiqh = {'formatif': (mapel['fiqih'] ?? 80), 'sumatif': (mapel['fiqih'] ?? 80)};
      bahasa = {'formatif': (mapel['bahasaArab'] ?? 80), 'sumatif': (mapel['bahasaArab'] ?? 80)};

      // Akhlak may be a number; if so, distribute into components
      if (doc['akhlak'] is Map<String, dynamic>) {
        akhlak = Map<String, dynamic>.from(doc['akhlak']);
      } else {
        final num v = (doc['akhlak'] ?? 80) as num;
        akhlak = {'disiplin': v, 'adab': v, 'kebersihan': v, 'kerjasama': v};
      }

      // Kehadiran may be object of hadir/izin/sakit/alpha or labels h/s/i/a
      if (doc['kehadiran'] is Map<String, dynamic>) {
        final k = Map<String, dynamic>.from(doc['kehadiran']);
        kehadiran = {
          'h': k['hadir'] ?? k['h'] ?? 0,
          's': k['sakit'] ?? k['s'] ?? 0,
          'i': k['izin'] ?? k['i'] ?? 0,
          'a': k['alpha'] ?? k['a'] ?? 0,
        };
      } else {
        kehadiran = {'h': 0, 's': 0, 'i': 0, 'a': 0};
      }

      return {
        'tahfidz': tahfidz,
        'fiqh': fiqh,
        'bahasa': bahasa,
        'akhlak': akhlak,
        'kehadiran': kehadiran,
      };
    }

    // Live stream from Firestore penilaian; fallback to local sample if empty
    // First stream santri info from Firestore, then stream penilaian
    return StreamBuilder<Santri?>(
      stream: FirestoreService.watchSantriById(id),
      builder: (context, santriSnap) {
        final santri = santriSnap.data;
        if (santri == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        // Prefer top-level 'penilaian' collection if available; fallback to subcollection
        return StreamBuilder<Map<String, dynamic>?>(
          stream: FirestoreService.watchPenilaianTopLevel(id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            final data = snapshot.data;
            if (data == null) {
              // fallback to subcollection stream
              return StreamBuilder<Map<String, dynamic>?>(
                stream: FirestoreService.watchPenilaian(id),
                builder: (context, snap2) {
                  final d2 = snap2.data;
                  if (d2 == null) return buildFrom(santri, fallbackScores, context);
                  return buildFrom(santri, _normalizeFirestorePenilaian(d2), context);
                },
              );
            }
            return buildFrom(santri, _normalizeFirestorePenilaian(data), context);
          },
        );
      },
    );
  }
}
