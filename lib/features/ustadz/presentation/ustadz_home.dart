import 'package:flutter/material.dart';
import '../../auth/providers/auth_provider.dart';

class UstadzHomePage extends StatelessWidget {
  const UstadzHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ustadz - Dashboard'), actions: [
        IconButton(onPressed: () async { await signOut(); if (context.mounted) Navigator.of(context).pushReplacementNamed('/'); }, icon: const Icon(Icons.logout)),
      ]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Card(child: ListTile(leading: const Icon(Icons.edit_note_outlined), title: const Text('Input Penilaian'), subtitle: const Text('Masukkan penilaian harian/mingguan'), onTap: () => Navigator.of(context).pushNamed('/ustadz/input'))),
          const SizedBox(height: 8),
          Card(child: ListTile(leading: const Icon(Icons.list), title: const Text('Daftar Santri'), subtitle: const Text('Lihat dan pilih santri'), onTap: () => Navigator.of(context).pushNamed('/santri'))),
        ]),
      ),
    );
  }
}
