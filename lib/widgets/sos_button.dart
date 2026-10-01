import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../theme/app_theme.dart';

class SosButton extends StatefulWidget {
  final VoidCallback onTriggered;
  final Duration holdDuration;

  const SosButton({
    super.key,
    required this.onTriggered,
    this.holdDuration = const Duration(seconds: 3),
  });

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _hapticTimer;
  bool _isHolding = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.holdDuration,
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _trigger();
      }
    });
  }

  @override
  void dispose() {
    _hapticTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startHold() {
    if (_isHolding) return;
    setState(() => _isHolding = true);
    _controller.forward(from: 0);

    _hapticTimer = Timer.periodic(const Duration(milliseconds: 200), (_) async {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(duration: 40);
      }
    });
  }

  void _cancelHold() {
    if (!_isHolding) return;
    _hapticTimer?.cancel();
    _controller.stop();
    _controller.reset();
    setState(() => _isHolding = false);
  }

  void _trigger() async {
    _hapticTimer?.cancel();
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(pattern: [0, 200, 100, 200, 100, 500]);
    }
    setState(() => _isHolding = false);
    _controller.reset();
    widget.onTriggered();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _startHold(),
      onTapUp: (_) => _cancelHold(),
      onTapCancel: _cancelHold,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final progress = _controller.value;
          return SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: AppColors.danger.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation(AppColors.danger),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _isHolding ? 180 : 190,
                  height: _isHolding ? 180 : 190,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.danger, AppColors.dangerDark],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.danger
                            .withValues(alpha: _isHolding ? 0.6 : 0.4),
                        blurRadius: _isHolding ? 40 : 20,
                        spreadRadius: _isHolding ? 8 : 0,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.sos, color: Colors.white, size: 56),
                      const SizedBox(height: 4),
                      Text(
                        _isHolding ? 'HOLD...' : 'HOLD',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        _isHolding ? 'Release to cancel' : 'FOR SOS',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}