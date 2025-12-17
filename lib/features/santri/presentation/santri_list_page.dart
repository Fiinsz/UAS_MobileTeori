import 'package:flutter/material.dart';
import '../providers/santri_provider.dart';
import '../../../core/services/firestore_service.dart';

class SantriListPage extends StatefulWidget {
  const SantriListPage({super.key});

  @override
  State<SantriListPage> createState() => _SantriListPageState();
}

class _SantriListPageState extends State<SantriListPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final state = currentSantriState;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Santri'),
        actions: [IconButton(onPressed: () => Navigator.of(context).pushNamed('/settings'), icon: const Icon(Icons.settings))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: TextField(
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Cari nama...'),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder(
                stream: FirestoreService.watchSantri(),
                builder: (context, snapshot) {
                  final data = snapshot.data ?? state.list;
                  final list = data.where((s) => s.nama.toLowerCase().contains(_query.toLowerCase())).toList();
                  if (snapshot.connectionState == ConnectionState.waiting && list.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (list.isEmpty) {
                    return const Center(child: Text('Belum ada data santri'));
                  }
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, idx) {
                      final s = list[idx];
                      final synced = !state.unsyncedIds.contains(s.id);
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.secondary, child: Text(s.nama.isNotEmpty ? s.nama[0] : '?')),
                          title: Text(s.nama, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('${s.nis} • ${s.kamar} • ${s.angkatan}'),
                          trailing: Wrap(spacing: 8, children: [
                            Icon(synced ? Icons.cloud_done : Icons.cloud_off, color: synced ? Colors.green : Colors.red),
                            IconButton(
                              tooltip: 'Input Penilaian',
                              icon: const Icon(Icons.edit_note),
                              onPressed: () => Navigator.of(context).pushNamed('/ustadz/input', arguments: {'santriId': s.id}),
                            ),
                          ]),
                          onTap: () => Navigator.of(context).pushNamed('/santri/detail', arguments: {'id': s.id}),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
