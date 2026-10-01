
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, size: 48, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text('AEGIS User',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(user?.email?.replaceAll('@aegis.local', '') ?? 'Unknown',
                  style: const TextStyle(color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 40),
            const Text('Coming soon:',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('• Edit name'),
            const Text('• Privacy controls'),
            const Text('• App preferences'),
          ],
        ),
      ),
    );
  }
}