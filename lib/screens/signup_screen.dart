import 'package:flutter/material.dart';
import '../services/mock_auth_service.dart';

import 'contacts_setup_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth = MockAuthService();
  bool _loading = false;

  Future<void> _signUp() async {
    if (_nameCtrl.text.isEmpty || _phoneCtrl.text.length < 10 || _passCtrl.text.length < 6) return;
    setState(() => _loading = true);
    await _auth.signUp(name: _nameCtrl.text.trim(), phone: _phoneCtrl.text.trim(), password: _passCtrl.text);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const ContactsSetupScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create account', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 32),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'Full Name')),
            const SizedBox(height: 20),
            TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, maxLength: 10, decoration: const InputDecoration(hintText: 'Phone Number', counterText: '')),
            const SizedBox(height: 20),
            TextField(controller: _passCtrl, obscureText: true, decoration: const InputDecoration(hintText: 'Password (6+ chars)')),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: _loading ? null : _signUp, child: _loading ? const CircularProgressIndicator() : const Text('Create Account')),
          ],
        ),
      ),
    );
  }
}