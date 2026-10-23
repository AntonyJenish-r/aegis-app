import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alert_model.dart';

class MockAlertService {
  static const _keyAlerts = 'mock_alerts';

  Future<String> createAlert({
    required String triggerType,
    required double aiScore,
    String? notes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_keyAlerts) ?? [];
    
    final alert = AlertModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'mock_user_123',
      triggerType: triggerType,
      aiScore: aiScore,
      latitude: 13.0827, // Mock location
      longitude: 80.2707,
      createdAt: DateTime.now(),
      status: 'PENDING',
      notes: notes,
    );

    data.add(jsonEncode(alert.toMap()));
    await prefs.setStringList(_keyAlerts, data);
    return alert.id;
  }

  Stream<List<AlertModel>> streamMyAlerts() async* {
    while (true) {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getStringList(_keyAlerts) ?? [];
      final alerts = data.map((e) => AlertModel.fromMap(jsonDecode(e))).toList();
      yield alerts.reversed.toList();
      await Future.delayed(const Duration(seconds: 2));
    }
  }
}