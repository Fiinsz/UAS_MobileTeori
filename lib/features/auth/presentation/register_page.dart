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

  Future<void> _register() async {
    setState(() => _loading = true);
    // Register hanya untuk wali santri
    final ok = await registerWithEmailPassword(
      email: _email.text.trim(),
      password: _password.text,
      displayName: _name.text.trim(),
      role: 'wali',
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
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nama')), 
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')), 
            TextField(controller: _password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 8),
            const Text('Role: Wali Santri', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loading ? null : _register, child: _loading ? const CircularProgressIndicator() : const Text('Daftar')),
          ],
        ),
      ),
    );
  }
}
