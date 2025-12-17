import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/santri/providers/santri_provider.dart';
import '../models/santri.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  static Future<void> seedInitialData() async {
    try {
      final santriRef = _db.collection('santri');
      // Write santri list
      for (final s in currentSantriState.list) {
        await santriRef.doc(s.id).set({
          'id': s.id,
          'nis': s.nis,
          'nama': s.nama,
          'kamar': s.kamar,
          'angkatan': s.angkatan,
        }, SetOptions(merge: true));
      }
      // Example penilaian per santri
      for (final s in currentSantriState.list) {
        final scores = sampleScoresFor(s.id);
        await santriRef.doc(s.id).collection('penilaian').doc('contoh').set(scores, SetOptions(merge: true));
      }
      log('Seeded initial santri & penilaian to Firestore');
    } catch (e, st) {
      log('Seeding Firestore failed: $e', stackTrace: st);
    }
  }

  static Stream<List<Santri>> watchSantri() {
    return _db.collection('santri').snapshots().map((snap) => snap.docs.map((d) {
          final data = d.data();
          return Santri(
            id: data['id'] ?? d.id,
            nis: data['nis'] ?? '',
            nama: data['nama'] ?? '',
            kamar: data['kamar'] ?? '',
            angkatan: (data['angkatan'] ?? 0) as int,
          );
        }).toList());
  }

  static Stream<Santri?> watchSantriById(String id) {
    return _db.collection('santri').doc(id).snapshots().map((d) {
      final data = d.data();
      if (data == null) return null;
      return Santri(
        id: data['id'] ?? d.id,
        nis: data['nis'] ?? '',
        nama: data['nama'] ?? '',
        kamar: data['kamar'] ?? '',
        angkatan: (data['angkatan'] ?? 0) as int,
      );
    });
  }

  /// Stream latest penilaian document for a given santri id.
  /// It orders by Firestore update time if available; otherwise picks the first doc.
  static Stream<Map<String, dynamic>?> watchPenilaian(String santriId) {
    final col = _db.collection('santri').doc(santriId).collection('penilaian');
    // If you add a field like `updatedAt` (Timestamp), you can orderBy it here.
    return col.snapshots().map((snap) {
      if (snap.docs.isEmpty) return null;
      // Pick the first doc; optionally choose by name e.g., 'semester1'.
      final data = snap.docs.first.data();
      return data;
    });
  }

  /// Top-level penilaian collection variant: penilaian docs keyed by santriId/semester
  static Stream<Map<String, dynamic>?> watchPenilaianTopLevel(String santriId) {
    final col = _db.collection('penilaian');
    return col.where('santriId', isEqualTo: santriId).orderBy('updatedAt', descending: true).limit(1).snapshots().map((snap) {
      if (snap.docs.isEmpty) return null;
      return snap.docs.first.data();
    });
  }

  static Future<void> addOrUpdateSantri(Santri s) async {
    await _db.collection('santri').doc(s.id).set({
      'id': s.id,
      'nis': s.nis,
      'nama': s.nama,
      'kamar': s.kamar,
      'angkatan': s.angkatan,
    }, SetOptions(merge: true));
  }

  static Future<void> deleteSantri(String id) async {
    await _db.collection('santri').doc(id).delete();
  }

  static Future<void> savePenilaian({
    required String santriId,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    final payload = {
      ...data,
      'santriId': santriId,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // Write to subcollection under santri
    await _db
        .collection('santri')
        .doc(santriId)
        .collection('penilaian')
        .doc(docId)
        .set(payload, SetOptions(merge: true));

    // Also mirror to top-level 'penilaian' collection for simpler querying
    await _db.collection('penilaian').doc(docId).set(payload, SetOptions(merge: true));
  }
}
