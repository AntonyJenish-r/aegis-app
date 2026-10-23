import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/mock_auth_service.dart';
import '../services/audio_monitor_service.dart';
import '../services/emergency_call_service.dart'; 
import '../theme/app_theme.dart';
import '../widgets/sos_button.dart';
import 'sos_countdown_screen.dart';
import 'contacts_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'fake_call_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = MockAuthService();
  final _audioMonitor = AudioMonitorService();
  final _callService = EmergencyCallService(); 
  bool _monitoring = false;
  String _userName = 'User';
  double _score = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _requestPermissions();
  }

  Future<void> _loadUser() async {
    final profile = await _auth.getUserProfile(_auth.mockUserId);
    if (mounted && profile != null) setState(() => _userName = profile['name']);
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
    await Permission.location.request();
  }

  Future<void> _toggleMonitoring(bool val) async {
    if (val) {
      final started = await _audioMonitor.start();
      if (started) {
        setState(() => _monitoring = true);
        _audioMonitor.scores.listen((s) {
          if (mounted) setState(() => _score = s);
        });
      }
    } else {
      await _audioMonitor.stop();
      setState(() { _monitoring = false; _score = 0; });
    }
  }

  void _triggerFakeCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fake call incoming in 5 seconds...')),
    );
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const FakeCallScreen(callerName: 'Dad')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hello, $_userName', style: const TextStyle(color: AppColors.textSecondary)),
                      const Text('You are safe', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.safe)),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.person), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shield, color: AppColors.primary),
                        const SizedBox(width: 12),
                        const Expanded(child: Text('AI Monitoring')),
                        Switch(value: _monitoring, onChanged: _toggleMonitoring, activeThumbColor: AppColors.safe),
                      ],
                    ),
                    if (_monitoring) ...[
                      const SizedBox(height: 10),
                      LinearProgressIndicator(value: _score / 100, color: _score > 75 ? AppColors.danger : AppColors.safe),
                      const SizedBox(height: 5),
                      Text('Score: ${_score.toStringAsFixed(1)} / 100'),
                    ]
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              Center(child: SosButton(onTriggered: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SosCountdownScreen())))),
              
              const SizedBox(height: 40),

              // FAKE CALL BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade800,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _triggerFakeCall,
                  icon: const Icon(Icons.phone_callback, color: Colors.white),
                  label: const Text('Fake Call from Dad', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),

              const SizedBox(height: 30),

              // EMERGENCY NUMBERS GRID
              const Text('Emergency Numbers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _EmergencyButton(label: 'Police', number: '100', icon: Icons.local_police, color: Colors.blue, onTap: () => _callService.callPolice()),
                  _EmergencyButton(label: 'Women', number: '1091', icon: Icons.support_agent, color: Colors.pink, onTap: () => _callService.callWomenHelpline()),
                  _EmergencyButton(label: 'Ambulance', number: '108', icon: Icons.local_hospital, color: Colors.green, onTap: () => _callService.callAmbulance()),
                ],
              ),

              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(child: ElevatedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactsScreen())), icon: const Icon(Icons.contacts), label: const Text('Contacts'))),
                  const SizedBox(width: 10),
                  Expanded(child: ElevatedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())), icon: const Icon(Icons.history), label: const Text('History'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmergencyButton extends StatelessWidget {
  final String label;
  final String number;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _EmergencyButton({required this.label, required this.number, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(number, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}