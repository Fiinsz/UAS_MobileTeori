import 'package:flutter/material.dart';

class AdminMapelPage extends StatefulWidget {
  const AdminMapelPage({super.key});

  @override
  State<AdminMapelPage> createState() => _AdminMapelPageState();
}

class _AdminMapelPageState extends State<AdminMapelPage> {
  List<String> mapels = ['Tahfidz', 'Fiqh', 'Bahasa Arab', 'Akhlak', 'Kehadiran'];

  void _addMapel() {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Tambah Mata Pelajaran'),
      content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Nama Mapel')),
      actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal')), ElevatedButton(onPressed: (){ setState(()=>mapels.add(ctrl.text)); Navigator.of(ctx).pop(); }, child: const Text('Tambah'))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mata Pelajaran & Rubrik')),
      floatingActionButton: FloatingActionButton(onPressed: _addMapel, child: const Icon(Icons.add)),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: mapels.length,
        itemBuilder: (context, idx) => Card(child: ListTile(title: Text(mapels[idx]), trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => setState(()=>mapels.removeAt(idx))))),
      ),
    );
  }
}
