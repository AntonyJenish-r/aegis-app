import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../services/alert_service.dart';
import '../theme/app_theme.dart';
import 'active_emergency_screen.dart';

class SosCountdownScreen extends StatefulWidget {
  const SosCountdownScreen({super.key});

  @override
  State<SosCountdownScreen> createState() => _SosCountdownScreenState();
}

class _SosCountdownScreenState extends State<SosCountdownScreen> {
  int _secondsLeft = 5;
  Timer? _timer;
  final _alertService = AlertService();

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(pattern: [0, 100, 200, 100, 200, 100]);
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(duration: 80);
      }
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        t.cancel();
        await _triggerAlert();
      }
    });
  }

  Future<void> _triggerAlert() async {
    try {
      final alertId = await _alertService.createAlert(
        triggerType: 'MANUAL_SOS',
        aiScore: 100,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ActiveEmergencyScreen(alertId: alertId)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      Navigator.of(context).pop();
    }
  }

  void _cancel() {
    _timer?.cancel();
    Vibration.cancel();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (5 - _secondsLeft) / 5;

    return Scaffold(
      backgroundColor: AppColors.danger,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Sending SOS in',
                  style: TextStyle(color: Colors.white70, fontSize: 18, letterSpacing: 1)),
              const SizedBox(height: 24),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 10,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  Text('$_secondsLeft',
                      style: const TextStyle(color: Colors.white, fontSize: 96, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 40),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Your location will be sent to your emergency contacts.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 220,
                child: ElevatedButton(
                  onPressed: _cancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.danger,
                    minimumSize: const Size.fromHeight(60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('CANCEL',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}