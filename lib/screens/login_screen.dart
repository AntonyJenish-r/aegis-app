import 'package:flutter/material.dart';
import '../services/mock_auth_service.dart';
import '../theme/app_theme.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'contacts_setup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth = MockAuthService();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _phoneCtrl.dispose(); _passCtrl.dispose(); super.dispose();
  }

  Future<void> _login() async {
    final phone = _phoneCtrl.text.trim();
    final password = _passCtrl.text;
    if (phone.length < 10) { setState(() => _error = 'Enter valid 10-digit number'); return; }
    if (password.length < 6) { setState(() => _error = 'Password must be 6+ chars'); return; }

    setState(() { _loading = true; _error = null; });

    try {
      await _auth.login(phone: phone, password: password);
      final profile = await _auth.getUserProfile(_auth.mockUserId);
      final setupDone = profile?['contactsSetupComplete'] == true;
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => setupDone ? const HomeScreen() : const ContactsSetupScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = 'Mock login failed'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Container(width: 64, height: 64, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.shield_moon, color: Colors.white, size: 36)),
              const SizedBox(height: 32),
              Text('Welcome back', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('Log in (Offline Mode)', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 40),
              TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, maxLength: 10, decoration: const InputDecoration(hintText: '98765 43210', counterText: '', prefixIcon: Padding(padding: EdgeInsets.all(16), child: Text('+91', style: TextStyle(fontWeight: FontWeight.bold))))),
              const SizedBox(height: 20),
              TextField(controller: _passCtrl, obscureText: _obscure, decoration: InputDecoration(hintText: '••••••••', suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscure = !_obscure)))),
              if (_error != null) ...[const SizedBox(height: 12), Text(_error!, style: const TextStyle(color: AppColors.danger))],
              const SizedBox(height: 32),
              ElevatedButton(onPressed: _loading ? null : _login, child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Log In')),
              const SizedBox(height: 20),
              Center(child: TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())), child: const Text('Create New Account'))),
            ],
          ),
        ),
      ),
    );
  }
}