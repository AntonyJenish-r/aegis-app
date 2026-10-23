import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/contact_model.dart';

class MockContactService {
  static const _keyContacts = 'mock_contacts';

  Future<List<EmergencyContact>> getContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_keyContacts) ?? [];
    return data.map((e) => EmergencyContact.fromMap(jsonDecode(e))).toList();
  }

  Future<void> addContact(EmergencyContact contact) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_keyContacts) ?? [];
    data.add(jsonEncode(contact.toMap()));
    await prefs.setStringList(_keyContacts, data);
  }

  Future<void> deleteContact(String contactId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_keyContacts) ?? [];
    data.removeWhere((e) => jsonDecode(e)['id'] == contactId);
    await prefs.setStringList(_keyContacts, data);
  }
}