import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/alert_model.dart';
import 'sms_service.dart';
import 'contact_service.dart';

class AlertService {
  // Singleton pattern
  static final AlertService _instance = AlertService._internal();
  factory AlertService() => _instance;
  AlertService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  StreamSubscription<Position>? _liveTrackingSub;

  /// Start live tracking that works in the background
  void startLiveTracking(String alertId) {
    _liveTrackingSub?.cancel();

    late LocationSettings locationSettings;
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 10),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText: "AEGIS is sharing your live location with your emergency contacts.",
          notificationTitle: "AEGIS Emergency Active",
          enableWakeLock: true,
        ),
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );
    }

    _liveTrackingSub = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position? position) {
      if (position != null) {
        _supabase.from('alerts').update({
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy_meters': position.accuracy,
        }).eq('id', alertId).then((_) {}).catchError((_) {});
      }
    });
  }

  /// Stop live tracking
  void stopLiveTracking() {
    _liveTrackingSub?.cancel();
    _liveTrackingSub = null;
  }

  /// Create an alert, save to Supabase, and send SMS to emergency contacts.
  Future<String> createAlert({
    required String triggerType,
    required double aiScore,
    String? notes,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not logged in');

    // 1. Get current location
    Position? pos;
    try {
      pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      pos = await Geolocator.getLastKnownPosition();
    }

    // 2. Save alert to Supabase
    final response = await _supabase
        .from('alerts')
        .insert({
          'user_id': userId,
          'trigger_type': triggerType,
          'ai_score': aiScore,
          'latitude': pos?.latitude,
          'longitude': pos?.longitude,
          'accuracy_meters': pos?.accuracy,
          'status': 'PENDING',
          'notes': notes,
        })
        .select()
        .single();

    // 3. Fetch emergency contacts
    List<dynamic> contacts = [];
    try {
      contacts = await ContactService().getContacts();
    } catch (_) {}

    // 4. Build emergency message
    final profile = await _supabase
        .from('profiles')
        .select('name')
        .eq('id', userId)
        .maybeSingle();
    final userName = profile?['name'] as String? ?? 'A user';

    final smsService = SmsService();
    final message = smsService.buildEmergencyMessage(
      userName: userName,
      latitude: pos?.latitude,
      longitude: pos?.longitude,
      trigger: triggerType.replaceAll('_', ' '),
    );

    // 5. Always copy to clipboard (fallback for Chrome/web)
    await smsService.copyToClipboard(message);

    // 6. Open SMS app for the first contact (native)
    if (contacts.isNotEmpty) {
      final first = contacts.first;
      await smsService.sendSmsTo(
        phoneNumber: first.phoneNumber,
        message: message,
      );
    }

    final alertId = response['id'].toString();
    
    // 7. Start Live Background Tracking
    startLiveTracking(alertId);

    return alertId;
  }

  /// Stream of my alerts (latest first)
  Stream<List<AlertModel>> streamMyAlerts() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return const Stream.empty();

    return _supabase
        .from('alerts')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50)
        .map((data) => data
            .map((item) => AlertModel.fromMap(Map<String, dynamic>.from(item)))
            .toList());
  }
}