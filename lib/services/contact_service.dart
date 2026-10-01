import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/contact_model.dart';

class ContactService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all emergency contacts for the current user
  Future<List<EmergencyContact>> getContacts() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final data = await _supabase
          .from('contacts')
          .select()
          .eq('user_id', userId)
          .order('priority');

      return (data as List)
          .map((item) => EmergencyContact.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Add a new emergency contact
  Future<void> addContact(EmergencyContact contact) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not logged in');

    await _supabase.from('contacts').insert({
      'user_id': userId,
      'name': contact.name,
      'phone_number': contact.phoneNumber,
      'relationship': contact.relationship,
      'priority': contact.priority,
    });
  }

  /// Delete a contact
  Future<void> deleteContact(String contactId) async {
    await _supabase.from('contacts').delete().eq('id', contactId);
  }
}