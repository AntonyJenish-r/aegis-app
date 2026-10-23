import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MockAuthService {
  static const _keyUser = 'mock_current_user';
  
  // ⭐ INTHA LINE THAAN MISS AAGIRUNDHATHU ⭐
  final String mockUserId = 'mock_user_123'; 

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyUser);
    if (data != null) return jsonDecode(data);
    return null;
  }

  Future<void> signUp({
    required String name,
    required String phone,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final user = {
      'uid': mockUserId,
      'name': name,
      'phone': phone,
      'contactsSetupComplete': false,
    };
    await prefs.setString(_keyUser, jsonEncode(user));
  }

  Future<void> login({
    required String phone,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyUser);
    if (data == null) {
      await signUp(name: 'Mock User', phone: phone, password: password);
    }
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyUser);
    if (data != null) {
      final user = jsonDecode(data);
      user.addAll(updates);
      await prefs.setString(_keyUser, jsonEncode(user));
    }
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
  }
}