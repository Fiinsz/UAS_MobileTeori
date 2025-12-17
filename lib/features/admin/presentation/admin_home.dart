import 'package:flutter/material.dart';
import '../../auth/providers/auth_provider.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin - Dashboard'), actions: [
        IconButton(onPressed: () async { await signOut(); if (context.mounted) Navigator.of(context).pushReplacementNamed('/'); }, icon: const Icon(Icons.logout)),
      ]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.people_alt_outlined),
              title: const Text('Data Santri'),
              subtitle: const Text('CRUD Santri (NIS, nama, kamar, angkatan)'),
              onTap: () => Navigator.of(context).pushNamed('/admin/santri'),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.manage_accounts_outlined),
              title: const Text('Kelola Akun'),
              subtitle: const Text('CRUD pengguna & role'),
              onTap: () => Navigator.of(context).pushNamed('/admin/users'),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.book_outlined),
              title: const Text('Mata Pelajaran & Rubrik'),
              subtitle: const Text('Kelola Mapel, Rubrik Akhlak'),
              onTap: () => Navigator.of(context).pushNamed('/admin/mapel'),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.tune),
              title: const Text('Konfigurasi Bobot'),
              subtitle: const Text('Atur bobot per aspek'),
              onTap: () => Navigator.of(context).pushNamed('/admin/bobot'),
            ),
          ),
        ]),
      ),
    );
  }
}
