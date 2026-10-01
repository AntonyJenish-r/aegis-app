import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/alert_service.dart';
import '../theme/app_theme.dart';

class ActiveEmergencyScreen extends StatelessWidget {
  final String alertId;

  const ActiveEmergencyScreen({super.key, required this.alertId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dangerDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.shield, color: Colors.white, size: 80),
              const SizedBox(height: 24),
              const Text('EMERGENCY ACTIVE',
                  style: TextStyle(color: Colors.white, fontSize: 28,
                      fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 12),
              const Text('Your alert has been sent.',
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 4),
              Text('Alert ID: ${alertId.substring(0, 8)}',
                  style: const TextStyle(color: Colors.white38, fontSize: 12)),
              const SizedBox(height: 40),
              const _StatusRow(icon: Icons.check_circle, text: 'Alert logged'),
              const SizedBox(height: 12),
              const _StatusRow(icon: Icons.sync, text: 'Notifying contacts...'),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'If you are safe, tap below to cancel the emergency.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Update status in Supabase to mark as safe
                    await Supabase.instance.client
                        .from('alerts')
                        .update({'status': 'RESOLVED'})
                        .eq('id', alertId)
                        .catchError((_) {});
                    
                    // Stop live tracking
                    AlertService().stopLiveTracking();

                    if (context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.danger,
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child: const Text("I'M SAFE — STOP ALERT",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _StatusRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }
}