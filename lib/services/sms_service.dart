import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../models/contact_model.dart';

/// SMS Service — sends emergency alerts to contacts.
///
/// Uses the native SMS app (via url_launcher) with a prefilled message.
/// The user taps "Send" once — this is intentional to avoid silent mass SMS.
class SmsService {
  /// Build the emergency message with live location.
  String buildEmergencyMessage({
    required String userName,
    required double? latitude,
    required double? longitude,
    String trigger = 'SOS',
  }) {
    final locationPart = (latitude != null && longitude != null)
        ? '\nMy live location: https://maps.google.com/?q=$latitude,$longitude'
        : '\n(Location unavailable)';

    return '🚨 EMERGENCY — $trigger\n'
        '$userName needs immediate help.$locationPart\n'
        'Please call or come immediately.';
  }

  /// Open the SMS app with a prefilled message to one contact.
  Future<bool> sendSmsTo({
    required String phoneNumber,
    required String message,
  }) async {
    final clean = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('sms:$clean?body=${Uri.encodeComponent(message)}');

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

  /// Send to ALL emergency contacts (opens SMS app for each one sequentially).
  Future<int> sendToAll({
    required List<EmergencyContact> contacts,
    required String message,
  }) async {
    int sent = 0;
    for (final c in contacts) {
      final ok = await sendSmsTo(
        phoneNumber: c.phoneNumber,
        message: message,
      );
      if (ok) sent++;
      await Future.delayed(const Duration(milliseconds: 500));
    }
    return sent;
  }

  /// Fallback — copy message to clipboard (for web/Chrome testing).
  Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
}