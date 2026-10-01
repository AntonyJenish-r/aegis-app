import 'package:url_launcher/url_launcher.dart';

/// Emergency Call Service — one-tap dialing of emergency numbers.
class EmergencyCallService {
  /// India emergency numbers.
  static const String indiaEmergency = '112';   // All-in-one
  static const String police = '100';
  static const String ambulance = '108';
  static const String women = '1091';           // Women helpline

  /// Open the phone dialer with the given number prefilled.
  /// User just taps the green call button — no need to type.
  Future<bool> dial(String number) async {
    final clean = number.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$clean');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Dial 112 — India's unified emergency number.
  Future<bool> callEmergency() => dial(indiaEmergency);

  /// Dial women helpline 1091.
  Future<bool> callWomenHelpline() => dial(women);

  /// Dial police 100.
  Future<bool> callPolice() => dial(police);

  /// Dial ambulance 108.
  Future<bool> callAmbulance() => dial(ambulance);
}