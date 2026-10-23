import 'dart:async';
import 'package:flutter/material.dart';
import '../services/mock_alert_service.dart';
import '../theme/app_theme.dart';
import 'active_emergency_screen.dart';

class SosCountdownScreen extends StatefulWidget {
  const SosCountdownScreen({super.key});
  @override
  State<SosCountdownScreen> createState() => _SosCountdownScreenState();
}

class _SosCountdownScreenState extends State<SosCountdownScreen> {
  int _seconds = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      setState(() => _seconds--);
      if (_seconds <= 0) {
        t.cancel();
        final id = await MockAlertService().createAlert(triggerType: 'MANUAL_SOS', aiScore: 100);
        if (!mounted) return;
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ActiveEmergencyScreen(alertId: id)));
      }
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.danger,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$_seconds', style: const TextStyle(fontSize: 100, color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.danger),
              onPressed: () { _timer?.cancel(); Navigator.pop(context); },
              child: const Text('CANCEL'),
            )
          ],
        ),
      ),
    );
  }
}