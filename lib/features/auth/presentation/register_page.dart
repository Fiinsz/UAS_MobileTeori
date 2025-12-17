import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _loading = false;
  String? _selectedRole; // Role yang dipilih user

  // Daftar role yang tersedia untuk registrasi
  // Catatan: Role admin tidak tersedia untuk registrasi publik (hanya 1 super admin)
  final List<Map<String, String>> _roles = [
    {'value': 'wali', 'label': 'Wali Santri (Orang Tua)'},
    {'value': 'ustadz', 'label': 'Ustadz (Pengajar)'},
  ];

  Future<void> _register() async {
    // Validasi role harus dipilih
    if (_selectedRole == null || _selectedRole!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih role terlebih dahulu')),
      );
      return;
    }

    setState(() => _loading = true);
    final ok = await registerWithEmailPassword(
      email: _email.text.trim(),
      password: _password.text,
      displayName: _name.text.trim(),
      role: _selectedRole!, // Gunakan role yang dipilih user
    );
    setState(() => _loading = false);
    if (!mounted) return;
    if (ok) {
      // Redirect ke halaman pending approval
      Navigator.of(context).pushReplacementNamed('/pending-approval');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registrasi gagal')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Akun')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _email,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _password,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            // Dropdown untuk memilih role
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Pilih Role',
                border: OutlineInputBorder(),
                hintText: 'Pilih role Anda',
              ),
              items: _roles.map((role) {
                return DropdownMenuItem<String>(
                  value: role['value'],
                  child: Text(role['label']!),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRole = newValue;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Silakan pilih role';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Daftar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
