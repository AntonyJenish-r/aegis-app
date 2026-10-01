import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';
import '../services/audio_monitor_service.dart';
import '../services/emergency_call_service.dart';
import '../theme/app_theme.dart';
import '../widgets/sos_button.dart';
import 'sos_countdown_screen.dart';
import 'contacts_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = AuthService();
  final _locationService = LocationService();
  final _audioMonitor = AudioMonitorService();
  final _emergencyCall = EmergencyCallService();

  StreamSubscription<double>? _scoreSub;

  bool _monitoring = false;
  bool _alertTriggered = false;
  double _currentScore = 0;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _requestPermissions();
  }

  @override
  void dispose() {
    _scoreSub?.cancel();
    _audioMonitor.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    final profile = await _auth.getUserProfile(uid);
    if (mounted) {
      setState(() {
        _userName = profile?['name'] as String? ?? 'Friend';
      });
    }
  }

  Future<void> _requestPermissions() async {
    await _locationService.requestPermission();
    await Permission.microphone.request();
    await Permission.camera.request();
    await Permission.notification.request();
  }

  Future<void> _toggleMonitoring(bool value) async {
    if (value) {
      final micStatus = await Permission.microphone.status;
      if (!micStatus.isGranted) {
        final result = await Permission.microphone.request();
        if (!result.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Microphone permission required for AI monitoring'),
              ),
            );
          }
          return;
        }
      }

      final started = await _audioMonitor.start();
      if (!started) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not start microphone')),
          );
        }
        return;
      }

      _scoreSub = _audioMonitor.scores.listen((score) {
        if (!mounted) return;
        setState(() => _currentScore = score);

        if (!_alertTriggered && _audioMonitor.shouldTriggerAlert(score)) {
          _alertTriggered = true;
          _onAutoTrigger(score);
        }
      });

      setState(() => _monitoring = true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AI monitoring started — listening for distress'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      await _audioMonitor.stop();
      await _scoreSub?.cancel();
      _scoreSub = null;
      setState(() {
        _monitoring = false;
        _currentScore = 0;
        _alertTriggered = false;
      });
    }
  }

  void _onAutoTrigger(double score) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (_) => const SosCountdownScreen()),
        )
        .then((_) {
      if (mounted) {
        setState(() => _alertTriggered = false);
      }
    });
  }

  void _onSosTriggered() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SosCountdownScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = _currentScore >= 75
        ? AppColors.danger
        : _currentScore >= 40
            ? AppColors.accent
            : AppColors.safe;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hello, ${_userName ?? "..."}',
                            style: const TextStyle(
                                fontSize: 14, color: AppColors.textSecondary)),
                        const SizedBox(height: 2),
                        Text(
                          _monitoring ? 'AI is watching' : 'You are safe',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _monitoring
                                  ? AppColors.primary
                                  : AppColors.safe),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_outline),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // AI Monitoring Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: (_monitoring
                                    ? AppColors.safe
                                    : AppColors.textSecondary)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _monitoring ? Icons.shield : Icons.shield_outlined,
                            color: _monitoring
                                ? AppColors.safe
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('AI Monitoring',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15)),
                              Text(
                                _monitoring
                                    ? 'ACTIVE — listening for distress'
                                    : 'OFF — tap to enable',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: _monitoring
                                        ? AppColors.safe
                                        : AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _monitoring,
                          activeThumbColor: AppColors.safe,
                          onChanged: _toggleMonitoring,
                        ),
                      ],
                    ),
                    if (_monitoring) ...[
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('Distress score',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                          const Spacer(),
                          Text(
                            '${_currentScore.toStringAsFixed(1)} / 100',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: scoreColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _currentScore / 100,
                          minHeight: 6,
                          backgroundColor: AppColors.divider,
                          valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentScore >= 75
                            ? '⚠ HIGH distress detected — SOS in progress'
                            : _currentScore >= 40
                                ? 'Watching — elevated sound detected'
                                : 'Normal ambient',
                        style: TextStyle(
                            fontSize: 11,
                            color: scoreColor,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // SOS Button
              Center(
                child: SosButton(
                  onTriggered: _onSosTriggered,
                  holdDuration: const Duration(seconds: 3),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text('Hold for 3 seconds to send SOS',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
              ),
              const SizedBox(height: 40),

              // Emergency Call Buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.phone_in_talk,
                            color: AppColors.danger, size: 20),
                        SizedBox(width: 8),
                        Text('One-tap Emergency Call',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _EmergencyCallButton(
                            label: '112',
                            subtitle: 'All Emergency',
                            icon: Icons.emergency,
                            color: AppColors.danger,
                            onTap: () => _emergencyCall.callEmergency(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _EmergencyCallButton(
                            label: '1091',
                            subtitle: 'Women',
                            icon: Icons.support_agent,
                            color: const Color(0xFFD81B60),
                            onTap: () => _emergencyCall.callWomenHelpline(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _EmergencyCallButton(
                            label: '100',
                            subtitle: 'Police',
                            icon: Icons.local_police,
                            color: const Color(0xFF1E40AF),
                            onTap: () => _emergencyCall.callPolice(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _EmergencyCallButton(
                            label: '108',
                            subtitle: 'Ambulance',
                            icon: Icons.local_hospital,
                            color: AppColors.safe,
                            onTap: () => _emergencyCall.callAmbulance(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions
              const Text('Quick Actions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.contacts,
                      label: 'Contacts',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ContactsScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.history,
                      label: 'History',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HistoryScreen()),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Logout
              TextButton.icon(
                onPressed: () async {
                  await _audioMonitor.stop();
                  await _auth.signOut();
                  if (context.mounted) {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/', (route) => false);
                  }
                },
                icon: const Icon(Icons.logout, color: AppColors.textSecondary),
                label: const Text('Log out',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 26),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _EmergencyCallButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _EmergencyCallButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: color,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}