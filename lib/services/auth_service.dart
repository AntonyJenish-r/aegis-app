import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  String _phoneToEmail(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return '$digits@aegis.local';
  }

  Future<AuthResponse> signUp({
    required String name,
    required String phone,
    required String password,
  }) async {
    final email = _phoneToEmail(phone);

    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'phone': phone,
      },
    );

    if (response.user != null) {
      await _supabase.from('profiles').upsert({
        'id': response.user!.id,
        'name': name,
        'phone': phone,
        'contacts_setup_complete': false,
      });
    }

    return response;
  }

  Future<AuthResponse> login({
    required String phone,
    required String password,
  }) async {
    final email = _phoneToEmail(phone);
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return data;
    } catch (_) {
      return null;
    }
  }

  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> updates) async {
    await _supabase.from('profiles').update(updates).eq('id', userId);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  String readableError(Object e) {
    if (e is AuthException) {
      final msg = e.message.toLowerCase();
      if (msg.contains('already registered') || msg.contains('already exists')) {
        return 'This phone number is already registered. Please log in.';
      }
      if (msg.contains('invalid') || msg.contains('credentials')) {
        return 'Invalid phone number or password.';
      }
      if (msg.contains('weak') || msg.contains('password')) {
        return 'Password must be at least 6 characters.';
      }
      if (msg.contains('rate') || msg.contains('too many')) {
        return 'Too many attempts. Please try again later.';
      }
      return e.message;
    }
    return 'Something went wrong. Please try again.';
  }
}