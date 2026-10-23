import 'package:flutter/material.dart';
import '../services/mock_auth_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'contacts_setup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _auth = MockAuthService();

  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    try {
      final profile = await _auth.getUserProfile(_auth.mockUserId);
      if (profile == null) {
        _go(const LoginScreen());
      } else {
        final setupDone = profile['contactsSetupComplete'] == true;
        _go(setupDone ? const HomeScreen() : const ContactsSetupScreen());
      }
    } catch (e) {
      // Edhavadhu error vandha, direct-ah Login screen-ku pōgum
      _go(const LoginScreen());
    }
  }

  void _go(Widget screen) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: const Icon(Icons.shield_moon, size: 56, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            const Text('AEGIS', style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 6)),
            const SizedBox(height: 8),
            const Text('Your Safety. Instant Response.', style: TextStyle(fontSize: 14, color: Colors.white70)),
            const SizedBox(height: 48),
            const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
          ],
        ),
      ),
    );
  }
}