import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  // Role otomatis dari Firestore setelah login.

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _onLogin() {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email & password wajib')));
      return;
    }
    signInWithEmailPassword(email: email, password: pass)
        .then((_) {
      final role = currentAuth.role;
      if (role == Role.admin) {
        Navigator.of(context).pushReplacementNamed('/home/admin');
      } else if (role == Role.ustadz) {
        Navigator.of(context).pushReplacementNamed('/home/ustadz');
      } else if (role == Role.wali) {
        Navigator.of(context).pushReplacementNamed('/home/wali');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Role tidak dikenali')));
      }
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login gagal: $e')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login e-Penilaian')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Selamat datang', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Masuk untuk mengelola penilaian santri', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
                  const SizedBox(height: 8),
                  TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
                  const SizedBox(height: 8),
                  // Peran ditentukan otomatis dari Firestore (users/{uid}.role)
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _onLogin, child: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Login'))),
                  const SizedBox(height: 8),
                  TextButton(onPressed: () => Navigator.of(context).pushNamed('/register'), child: const Text('Daftar akun baru')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
