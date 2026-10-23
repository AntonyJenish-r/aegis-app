import 'package:url_launcher/url_launcher.dart';

class EmergencyCallService {
  Future<void> makeCall(String phoneNumber) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> callPolice() => makeCall('100');
  Future<void> callAmbulance() => makeCall('108');
  Future<void> callWomenHelpline() => makeCall('1091');
}