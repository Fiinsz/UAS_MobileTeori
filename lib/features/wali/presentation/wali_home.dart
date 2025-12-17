import 'package:flutter/material.dart';
import '../../auth/providers/auth_provider.dart';

class WaliHomePage extends StatelessWidget {
  const WaliHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wali Santri - Home'), actions: [
        IconButton(onPressed: () async { await signOut(); if (context.mounted) Navigator.of(context).pushReplacementNamed('/'); }, icon: const Icon(Icons.logout)),
      ]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Card(child: ListTile(leading: const Icon(Icons.person), title: const Text('Rapor Anak'), subtitle: const Text('Lihat rapor dan rekam jejak nilai'), onTap: () => Navigator.of(context).pushNamed('/santri'))),
          const SizedBox(height: 8),
          Card(child: ListTile(leading: const Icon(Icons.settings), title: const Text('Pengaturan'), onTap: () => Navigator.of(context).pushNamed('/settings'))),
        ]),
      ),
    );
  }
}
