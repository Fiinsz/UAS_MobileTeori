import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Helper function untuk admin membuat user dengan email dan password
/// CATATAN: Ini adalah workaround. Untuk production, gunakan Firebase Admin SDK di Cloud Functions
Future<bool> _createUserWithPassword({
  required String email,
  required String password,
  required String displayName,
  required String role,
}) async {
  try {
    // Simpan credential admin saat ini
    final adminUser = FirebaseAuth.instance.currentUser;
    if (adminUser == null) return false;
    
    // Create user baru - ini akan otomatis logout admin
    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    final newUserId = credential.user?.uid;
    if (newUserId == null) return false;
    
    // Simpan data user ke Firestore dengan approval fields
    // Admin-created users are auto-approved
    await FirebaseFirestore.instance.collection('users').doc(newUserId).set({
      'email': email,
      'displayName': displayName,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
      'isApproved': true, // Admin-created users are auto-approved
      'status': 'approved',
      'approvedBy': FirebaseAuth.instance.currentUser?.uid,
      'approvedAt': FieldValue.serverTimestamp(),
    });
    
    // Sign out user baru
    await FirebaseAuth.instance.signOut();
    
    // CATATAN: Admin perlu login kembali setelah ini
    // Alternatif: gunakan Cloud Functions dengan Admin SDK untuk create user tanpa logout
    
    return true;
  } catch (e) {
    print('Error creating user: $e');
    return false;
  }
}

/// Helper function untuk update password user
/// Note: Firebase tidak support update password user lain secara langsung
/// Solusi: simpan info di Firestore dan minta user reset password sendiri
/// ATAU gunakan Firebase Admin SDK di backend
Future<void> _updateUserPassword(String userId, String newPassword) async {
  // Untuk production, sebaiknya gunakan Cloud Function dengan Admin SDK
  // Untuk development, kita simpan ke Firestore sebagai petunjuk
  await FirebaseFirestore.instance.collection('users').doc(userId).set({
    'passwordResetRequired': true,
    'tempPassword': newPassword, // TIDAK AMAN! Hanya untuk demo
    'passwordUpdatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
  
  // Idealnya, trigger password reset email:
  // await FirebaseAuth.instance.sendPasswordResetEmail(email: userEmail);
}

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  String _filter = 'all'; // all, pending, approved, rejected

  Future<void> _approveUser(String userId) async {
    final adminUid = FirebaseAuth.instance.currentUser?.uid;
    if (adminUid == null) return;
    
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'isApproved': true,
      'status': 'approved',
      'approvedBy': adminUid,
      'approvedAt': FieldValue.serverTimestamp(),
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User berhasil disetujui')),
      );
    }
  }

  Future<void> _rejectUser(String userId) async {
    final adminUid = FirebaseAuth.instance.currentUser?.uid;
    if (adminUid == null) return;
    
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'isApproved': false,
      'status': 'rejected',
      'approvedBy': adminUid,
      'approvedAt': FieldValue.serverTimestamp(),
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ditolak')),
      );
    }
  }

  Future<void> _migrateAllUsers() async {
    final adminUid = FirebaseAuth.instance.currentUser?.uid;
    if (adminUid == null) return;
    
    try {
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      int migratedCount = 0;
      
      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        // Check if user doesn't have approval fields
        if (!data.containsKey('isApproved') || !data.containsKey('status')) {
          await doc.reference.update({
            'isApproved': true,
            'status': 'approved',
            'approvedBy': adminUid,
            'approvedAt': FieldValue.serverTimestamp(),
          });
          migratedCount++;
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$migratedCount user berhasil dimigrasi dan disetujui')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = FirebaseFirestore.instance.collection('users');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Akun'),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'migrate',
                child: Row(
                  children: [
                    Icon(Icons.update),
                    SizedBox(width: 8),
                    Text('Migrasi User Lama'),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'migrate') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Migrasi User Lama'),
                    content: const Text(
                      'Ini akan menyetujui semua user lama yang belum memiliki status approval. '
                      'User baru tetap memerlukan persetujuan manual. Lanjutkan?'
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Batal'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Migrasi'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await _migrateAllUsers();
                }
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'all', label: Text('Semua')),
                      ButtonSegment(value: 'pending', label: Text('Pending')),
                      ButtonSegment(value: 'approved', label: Text('Disetujui')),
                      ButtonSegment(value: 'rejected', label: Text('Ditolak')),
                    ],
                    selected: {_filter},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _filter = newSelection.first;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showDialog(context: context, builder: (_) => const _AddUserDialog());
        },
        child: const Icon(Icons.person_add_alt_1),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: users.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          var docs = snapshot.data!.docs;
          
          // Apply filter
          if (_filter != 'all') {
            docs = docs.where((doc) {
              final status = doc.data()['status'] as String? ?? 'pending';
              return status == _filter;
            }).toList();
          }
          
          // Sort: pending first, then by creation date
          docs.sort((a, b) {
            final aStatus = a.data()['status'] as String? ?? 'pending';
            final bStatus = b.data()['status'] as String? ?? 'pending';
            
            if (aStatus == 'pending' && bStatus != 'pending') return -1;
            if (aStatus != 'pending' && bStatus == 'pending') return 1;
            
            final aTime = a.data()['createdAt'] as Timestamp?;
            final bTime = b.data()['createdAt'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });
          
          if (docs.isEmpty) {
            return Center(
              child: Text(_filter == 'all' ? 'Belum ada akun' : 'Tidak ada akun dengan status $_filter'),
            );
          }
          
          // Count pending users
          final pendingCount = snapshot.data!.docs.where((doc) {
            final status = doc.data()['status'] as String? ?? 'pending';
            return status == 'pending';
          }).length;
          
          return Column(
            children: [
              if (pendingCount > 0)
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.orange.shade100,
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        'Ada $pendingCount akun menunggu persetujuan',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final d = docs[i].data();
                    final id = docs[i].id;
                    final status = d['status'] as String? ?? 'pending';
                    final role = d['role'] as String? ?? '';
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getStatusColor(status),
                              child: Icon(
                                _getStatusIcon(status),
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              d['displayName']?.toString().isNotEmpty == true 
                                  ? d['displayName'] 
                                  : (d['email'] ?? ''),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${d['email'] ?? ''} • Role: $role'),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    _buildStatusChip(status),
                                    if (d['approvedAt'] != null) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        'Disetujui: ${_formatTimestamp(d['approvedAt'] as Timestamp)}',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Hapus', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  await showDialog(
                                    context: context,
                                    builder: (_) => _EditUserDialog(id: id, initial: d),
                                  );
                                } else if (value == 'delete') {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Hapus User'),
                                      content: const Text('Yakin ingin menghapus user ini?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, false),
                                          child: const Text('Batal'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(ctx, true),
                                          child: const Text('Hapus'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await users.doc(id).delete();
                                  }
                                }
                              },
                            ),
                          ),
                          if (status == 'pending')
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _rejectUser(id),
                                      icon: const Icon(Icons.close),
                                      label: const Text('Tolak'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _approveUser(id),
                                      icon: const Icon(Icons.check),
                                      label: const Text('Setujui'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (status == 'rejected')
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: ElevatedButton.icon(
                                onPressed: () => _approveUser(id),
                                icon: const Icon(Icons.check),
                                label: const Text('Setujui Kembali'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'pending':
      default:
        return Icons.hourglass_empty;
    }
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    
    switch (status) {
      case 'approved':
        color = Colors.green;
        label = 'Disetujui';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Ditolak';
        break;
      case 'pending':
      default:
        color = Colors.orange;
        label = 'Menunggu';
        break;
    }
    
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 11, color: Colors.white),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _AddUserDialog extends StatefulWidget {
  const _AddUserDialog();
  @override
  State<_AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<_AddUserDialog> {
  final _email = TextEditingController();
  final _name = TextEditingController();
  final _password = TextEditingController();
  String _role = 'wali';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Akun'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nama')), 
          TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
          TextField(
            controller: _password,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _role,
            items: const [
              DropdownMenuItem(value: 'wali', child: Text('Wali')),
              DropdownMenuItem(value: 'ustadz', child: Text('Ustadz')),
              // Admin role dihapus - hanya ada 1 super admin
            ],
            onChanged: (v) => setState(() => _role = v ?? 'wali'),
            decoration: const InputDecoration(labelText: 'Role'),
          ),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(onPressed: () async {
          if (_password.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password harus diisi')),
            );
            return;
          }
          
          // Konfirmasi sebelum create user
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Konfirmasi'),
              content: const Text(
                'Membuat user baru akan logout admin sementara. '
                'Anda perlu login kembali setelahnya. Lanjutkan?'
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Lanjutkan'),
                ),
              ],
            ),
          );
          
          if (confirm != true) return;
          
          final result = await _createUserWithPassword(
            email: _email.text.trim(),
            password: _password.text.trim(),
            displayName: _name.text.trim(),
            role: _role,
          );
          
          if (context.mounted) {
            if (result) {
              Navigator.pop(context);
              // Redirect ke login
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User berhasil ditambahkan. Silakan login kembali.'),
                  duration: Duration(seconds: 3),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gagal menambahkan user')),
              );
            }
          }
        }, child: const Text('Simpan')),
      ],
    );
  }
}

class _EditUserDialog extends StatefulWidget {
  final String id;
  final Map<String, dynamic> initial;
  const _EditUserDialog({required this.id, required this.initial});
  @override
  State<_EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<_EditUserDialog> {
  late final TextEditingController _email = TextEditingController(text: widget.initial['email'] ?? '');
  late final TextEditingController _name = TextEditingController(text: widget.initial['displayName'] ?? '');
  final _password = TextEditingController();
  late String _role = (widget.initial['role'] ?? 'wali');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Akun'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nama')), 
          TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
          TextField(
            controller: _password,
            decoration: const InputDecoration(
              labelText: 'Password Baru (opsional)',
              hintText: 'Kosongkan jika tidak ingin mengubah',
            ),
            obscureText: true,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _role,
            items: const [
              DropdownMenuItem(value: 'wali', child: Text('Wali')),
              DropdownMenuItem(value: 'ustadz', child: Text('Ustadz')),
              // Admin role dihapus - hanya ada 1 super admin
            ],
            onChanged: (v) => setState(() => _role = v ?? 'wali'),
            decoration: const InputDecoration(labelText: 'Role'),
          ),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(onPressed: () async {
          final users = FirebaseFirestore.instance.collection('users');
          final updateData = <String, dynamic>{
            'email': _email.text.trim(),
            'displayName': _name.text.trim(),
            'role': _role,
          };
          
          // Note: Admin role tidak dapat diubah via UI - hanya ada 1 super admin
          
          await users.doc(widget.id).set(updateData, SetOptions(merge: true));
          
          // Update password jika diisi
          if (_password.text.trim().isNotEmpty) {
            await _updateUserPassword(widget.id, _password.text.trim());
          }
          
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User berhasil diupdate')),
            );
          }
        }, child: const Text('Simpan')),
      ],
    );
  }
}
