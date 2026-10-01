import 'dart:async';
import 'package:flutter/services.dart';

/// Audio Monitor Service — bridges to native Android AudioMonitor.
class AudioMonitorService {
  static const _methodChannel = MethodChannel('com.aegis.safety/audio_monitor');
  static const _eventChannel = EventChannel('com.aegis.safety/audio_scores');

  final _scoreController = StreamController<double>.broadcast();
  Stream<double> get scores => _scoreController.stream;

  StreamSubscription? _eventSub;
  bool _isRunning = false;
  DateTime? _lastTriggerAt;

  bool get isRunning => _isRunning;

  Future<bool> start() async {
    if (_isRunning) return true;
    try {
      final ok = await _methodChannel.invokeMethod<bool>('start') ?? false;
      if (!ok) return false;

      _eventSub = _eventChannel.receiveBroadcastStream().listen(
            (event) {
          if (event is num) _scoreController.add(event.toDouble());
        },
        onError: (e) => _scoreController.addError(e),
      );

      _isRunning = true;
      return true;
    } catch (e) {
      _isRunning = false;
      return false;
    }
  }

  Future<void> stop() async {
    if (!_isRunning) return;
    _isRunning = false;
    try {
      await _eventSub?.cancel();
      _eventSub = null;
      await _methodChannel.invokeMethod('stop');
    } catch (_) {}
  }

  bool shouldTriggerAlert(double score) {
    if (score < 75) return false;
    final now = DateTime.now();
    if (_lastTriggerAt != null && now.difference(_lastTriggerAt!).inSeconds < 30) {
      return false;
    }
    _lastTriggerAt = now;
    return true;
  }

  void dispose() {
    _eventSub?.cancel();
    _scoreController.close();
  }
}