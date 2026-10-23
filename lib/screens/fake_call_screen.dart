import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class FakeCallScreen extends StatefulWidget {
  final String callerName;
  const FakeCallScreen({super.key, this.callerName = 'Dad'});

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen> {
  @override
  void initState() {
    super.initState();
    // Ringtone vibration effect
    Vibration.vibrate(pattern: [1000, 1000, 1000, 1000], repeat: 0);
  }

  @override
  void dispose() {
    Vibration.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                const SizedBox(height: 50),
                const Text('Incoming call...', style: TextStyle(color: Colors.white70, fontSize: 18)),
                const SizedBox(height: 20),
                const CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white12,
                  child: Icon(Icons.person, size: 80, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text(widget.callerName, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text('Mobile', style: TextStyle(color: Colors.white54, fontSize: 16)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CallButton(
                    icon: Icons.call_end,
                    color: Colors.red,
                    onTap: () {
                      Vibration.cancel();
                      Navigator.pop(context);
                    },
                  ),
                  _CallButton(
                    icon: Icons.call,
                    color: Colors.green,
                    onTap: () {
                      Vibration.cancel();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connected...')));
                      Future.delayed(const Duration(seconds: 3), () => Navigator.pop(context));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _CallButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: CircleAvatar(
        radius: 40,
        backgroundColor: color,
        child: Icon(icon, color: Colors.white, size: 40),
      ),
    );
  }
}