import 'package:flutter/material.dart';
import '../../../core/models/santri.dart';
import '../../../core/services/firestore_service.dart';
import '../../santri/providers/santri_provider.dart';

class AdminSantriPage extends StatefulWidget {
  const AdminSantriPage({super.key});

  @override
  State<AdminSantriPage> createState() => _AdminSantriPageState();
}

class _AdminSantriPageState extends State<AdminSantriPage> {
  void _showForm({Santri? s}) {
    final nisCtrl = TextEditingController(text: s?.nis ?? '');
    final namaCtrl = TextEditingController(text: s?.nama ?? '');
    final kamarCtrl = TextEditingController(text: s?.kamar ?? '');
    final angkatanCtrl = TextEditingController(text: s?.angkatan.toString() ?? '2025');

    showDialog(context: context, builder: (ctx) {
      return AlertDialog(
        title: Text(s == null ? 'Tambah Santri' : 'Edit Santri'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nisCtrl, decoration: const InputDecoration(labelText: 'NIS')),
            TextField(controller: namaCtrl, decoration: const InputDecoration(labelText: 'Nama')),
            TextField(controller: kamarCtrl, decoration: const InputDecoration(labelText: 'Kamar')),
            TextField(controller: angkatanCtrl, decoration: const InputDecoration(labelText: 'Angkatan'), keyboardType: TextInputType.number),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal')),
          ElevatedButton(onPressed: () {
            final newS = Santri(id: s?.id ?? DateTime.now().millisecondsSinceEpoch.toString(), nis: nisCtrl.text, nama: namaCtrl.text, kamar: kamarCtrl.text, angkatan: int.tryParse(angkatanCtrl.text) ?? 0);
            FirestoreService.addOrUpdateSantri(newS).then((_) => setState(() {}));
            Navigator.of(ctx).pop();
          }, child: const Text('Simpan'))
        ],
      );
    });
  }

  void _delete(String id) {
    FirestoreService.deleteSantri(id).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CRUD Santri')),
      floatingActionButton: FloatingActionButton(onPressed: () => _showForm(), child: const Icon(Icons.add)),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: StreamBuilder<List<Santri>>(
          stream: FirestoreService.watchSantri(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final list = snapshot.data ?? currentSantriState.list;
            if (list.isEmpty) return const Center(child: Text('Belum ada data santri'));
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, idx) {
                final s = list[idx];
                return Card(
                  child: ListTile(
                    title: Text(s.nama),
                    subtitle: Text('${s.nis} • ${s.kamar} • ${s.angkatan}'),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _showForm(s: s)),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () => _delete(s.id)),
                    ]),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
