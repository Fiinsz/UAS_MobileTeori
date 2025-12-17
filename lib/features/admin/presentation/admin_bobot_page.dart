import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';

class AdminBobotPage extends StatefulWidget {
  const AdminBobotPage({super.key});

  @override
  State<AdminBobotPage> createState() => _AdminBobotPageState();
}

class _AdminBobotPageState extends State<AdminBobotPage> {
  late Map<String, TextEditingController> ctrls;

  @override
  void initState() {
    super.initState();
    ctrls = {
      for (final e in bobotDefault.entries) e.key: TextEditingController(text: (e.value * 100).toString())
    };
  }

  @override
  void dispose() {
    for (final c in ctrls.values) c.dispose();
    super.dispose();
  }

  void _save() {
    setState(() {
      bobotDefault = {
        for (final k in ctrls.keys) k: (double.tryParse(ctrls[k]!.text) ?? 0) / 100.0
      };
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bobot disimpan')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konfigurasi Bobot')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          ...ctrls.entries.map((e) => Padding(padding: const EdgeInsets.symmetric(vertical:8.0), child: TextField(controller: e.value, decoration: InputDecoration(labelText: '${e.key} (%)'), keyboardType: TextInputType.number))).toList(),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _save, child: const Text('Simpan Bobot'))
        ]),
      ),
    );
  }
}
