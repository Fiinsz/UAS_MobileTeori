import 'package:flutter/material.dart';
import '../../../core/services/calculations.dart';
import '../../../core/services/firestore_service.dart';

class InputPenilaianPage extends StatefulWidget {
  const InputPenilaianPage({super.key});

  @override
  State<InputPenilaianPage> createState() => _InputPenilaianPageState();
}

class _InputPenilaianPageState extends State<InputPenilaianPage> {
  String? _selectedSantriId;
  final _semesterCtrl = TextEditingController(text: 'semester1');
  final _tahunCtrl = TextEditingController(text: '2025/2026');

  // Tahfidz
  final _targetCtrl = TextEditingController(text: '50');
  final _setorCtrl = TextEditingController(text: '0');
  final _tajwidCtrl = TextEditingController(text: '0');

  // Mapel
  final _formatifCtrl = TextEditingController(text: '0');
  final _sumatifCtrl = TextEditingController(text: '0');

  // Akhlak
  int d = 4, a = 4, k = 4, j = 4;

  // Kehadiran
  final _hCtrl = TextEditingController(text: '0');
  final _sCtrl = TextEditingController(text: '0');
  final _iCtrl = TextEditingController(text: '0');
  final _aCtrl = TextEditingController(text: '0');

  Future<void> _save() async {
    if (_selectedSantriId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih santri terlebih dahulu')));
      return;
    }
    // Perform local compute and show summary (mock save)
    final tahf = Calculations.computeTahfidz(setor: int.tryParse(_setorCtrl.text) ?? 0, target: int.tryParse(_targetCtrl.text) ?? 1, tajwid: int.tryParse(_tajwidCtrl.text) ?? 0);
    final mapel = Calculations.computeMapel(formatif: int.tryParse(_formatifCtrl.text) ?? 0, sumatif: int.tryParse(_sumatifCtrl.text) ?? 0);
    final akhlak = Calculations.computeAkhlak(disiplin: d, adab: a, kebersihan: k, kerjasama: j);
    final keh = Calculations.computeKehadiran(h: int.tryParse(_hCtrl.text) ?? 0, s: int.tryParse(_sCtrl.text) ?? 0, i: int.tryParse(_iCtrl.text) ?? 0, a: int.tryParse(_aCtrl.text) ?? 0);

    final payload = {
      'tahfidz': {
        'setor': int.tryParse(_setorCtrl.text) ?? 0,
        'target': int.tryParse(_targetCtrl.text) ?? 1,
        'tajwid': int.tryParse(_tajwidCtrl.text) ?? 0,
      },
      'mapel': {
        'fiqih': int.tryParse(_formatifCtrl.text) ?? 0,
        'bahasaArab': int.tryParse(_sumatifCtrl.text) ?? 0,
      },
      'akhlak': {
        'disiplin': d,
        'adab': a,
        'kebersihan': k,
        'kerjasama': j,
      },
      'kehadiran': {
        'hadir': int.tryParse(_hCtrl.text) ?? 0,
        'sakit': int.tryParse(_sCtrl.text) ?? 0,
        'izin': int.tryParse(_iCtrl.text) ?? 0,
        'alpha': int.tryParse(_aCtrl.text) ?? 0,
      },
      'semester': _semesterCtrl.text.trim(),
      'tahun': _tahunCtrl.text.trim(),
    };

    await FirestoreService.savePenilaian(
      santriId: _selectedSantriId!,
      docId: _semesterCtrl.text.trim().isEmpty ? 'semester1' : _semesterCtrl.text.trim(),
      data: payload,
    );

    if (!mounted) return;
    showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Tersimpan'), content: Text('Nilai disimpan.\nTahfidz: $tahf\nMapel: $mapel\nAkhlak: $akhlak\nKehadiran: $keh'), actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Input Penilaian')),
      body: ListView(padding: const EdgeInsets.all(12), children: [
        Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
          StreamBuilder(
            stream: FirestoreService.watchSantri(),
            builder: (context, snapshot) {
              final list = snapshot.data ?? [];
              return DropdownButtonFormField<String>(
                value: _selectedSantriId,
                items: list.map((s) => DropdownMenuItem(value: s.id, child: Text(s.nama))).toList(),
                onChanged: (v)=>setState(()=>_selectedSantriId=v),
                decoration: const InputDecoration(labelText: 'Pilih Santri'),
              );
            },
          ),
          const SizedBox(height: 8),
          TextField(controller: _semesterCtrl, decoration: const InputDecoration(labelText: 'ID Dokumen Penilaian (mis: semester1)')),
          const SizedBox(height: 8),
          TextField(controller: _tahunCtrl, decoration: const InputDecoration(labelText: 'Tahun (mis: 2025/2026)')),
        ]))),

        const SizedBox(height: 8),
        Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Tahfidz', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height:8),
          TextField(controller: _targetCtrl, decoration: const InputDecoration(labelText: 'Target (ayat)'), keyboardType: TextInputType.number),
          const SizedBox(height:8),
          TextField(controller: _setorCtrl, decoration: const InputDecoration(labelText: 'Setoran (ayat)'), keyboardType: TextInputType.number),
          const SizedBox(height:8),
          TextField(controller: _tajwidCtrl, decoration: const InputDecoration(labelText: 'Tajwid (0-100)'), keyboardType: TextInputType.number),
        ]))),

        const SizedBox(height:8),
        Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Fiqh / Bahasa Arab (contoh - Mapel tunggal)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height:8),
          TextField(controller: _formatifCtrl, decoration: const InputDecoration(labelText: 'Formatif (0-100)'), keyboardType: TextInputType.number),
          const SizedBox(height:8),
          TextField(controller: _sumatifCtrl, decoration: const InputDecoration(labelText: 'Sumatif (0-100)'), keyboardType: TextInputType.number),
        ]))),

        const SizedBox(height:8),
        Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Akhlak (skala 1-4)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height:8),
          Row(children: [Text('Disiplin:'), const SizedBox(width:12), DropdownButton<int>(value: d, items: [1,2,3,4].map((i)=>DropdownMenuItem(value:i,child:Text('$i'))).toList(), onChanged: (v)=>setState(()=>d=v ?? d))]),
          Row(children: [Text('Adab:'), const SizedBox(width:12), DropdownButton<int>(value: a, items: [1,2,3,4].map((i)=>DropdownMenuItem(value:i,child:Text('$i'))).toList(), onChanged: (v)=>setState(()=>a=v ?? a))]),
          Row(children: [Text('Kebersihan:'), const SizedBox(width:12), DropdownButton<int>(value: k, items: [1,2,3,4].map((i)=>DropdownMenuItem(value:i,child:Text('$i'))).toList(), onChanged: (v)=>setState(()=>k=v ?? k))]),
          Row(children: [Text('Kerjasama:'), const SizedBox(width:12), DropdownButton<int>(value: j, items: [1,2,3,4].map((i)=>DropdownMenuItem(value:i,child:Text('$i'))).toList(), onChanged: (v)=>setState(()=>j=v ?? j))]),
        ]))),

        const SizedBox(height:8),
        Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Kehadiran', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height:8),
          TextField(controller: _hCtrl, decoration: const InputDecoration(labelText: 'Hadir (count)'), keyboardType: TextInputType.number),
          const SizedBox(height:8),
          TextField(controller: _sCtrl, decoration: const InputDecoration(labelText: 'Sakit (count)'), keyboardType: TextInputType.number),
          const SizedBox(height:8),
          TextField(controller: _iCtrl, decoration: const InputDecoration(labelText: 'Izin (count)'), keyboardType: TextInputType.number),
          const SizedBox(height:8),
          TextField(controller: _aCtrl, decoration: const InputDecoration(labelText: 'Alpa (count)'), keyboardType: TextInputType.number),
        ]))),

        const SizedBox(height:12),
        ElevatedButton(onPressed: _save, child: const Padding(padding: EdgeInsets.symmetric(vertical:12), child: Text('Simpan Penilaian'))),
      ]),
    );
  }
}
