import '../../../core/models/santri.dart';

// Minimal global state container (no Riverpod) for the prototype UI.
class SantriState {
  final List<Santri> list;
  final Set<String> unsyncedIds;

  SantriState({required this.list, Set<String>? unsyncedIds}) : unsyncedIds = unsyncedIds ?? {};
}

SantriState currentSantriState = SantriState(list: [
  const Santri(id: 's1', nis: '2025-001', nama: 'Ahmad F', kamar: 'A3', angkatan: 2023),
  const Santri(id: 's2', nis: '2025-002', nama: 'Bilal S', kamar: 'B1', angkatan: 2022),
], unsyncedIds: {'s2'});

Map<String, dynamic> sampleScoresFor(String santriId) {
  if (santriId == 's1') {
    return {
      'tahfidz': {'setor': 60, 'target': 50, 'tajwid': 85},
      'fiqh': {'formatif': 80, 'sumatif': 90},
      'bahasa': {'formatif': 75, 'sumatif': 80},
      'akhlak': {'disiplin': 4, 'adab': 4, 'kebersihan': 3, 'kerjasama': 4},
      'kehadiran': {'h': 18, 's': 1, 'i': 1, 'a': 0}
    };
  }
  return {
    'tahfidz': {'setor': 30, 'target': 50, 'tajwid': 78},
    'fiqh': {'formatif': 70, 'sumatif': 75},
    'bahasa': {'formatif': 60, 'sumatif': 65},
    'akhlak': {'disiplin': 3, 'adab': 3, 'kebersihan': 3, 'kerjasama': 2},
    'kehadiran': {'h': 14, 's': 2, 'i': 1, 'a': 3}
  };
}
