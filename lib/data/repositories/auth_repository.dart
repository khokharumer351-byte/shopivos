import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_config.dart';
import '../supabase_client.dart';

class AuthRepository {
  GoTrueClient get _auth => supabase.auth;

  User? get currentUser => _auth.currentUser;

  Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithPassword(email: email.trim(), password: password);
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _auth.signUp(
      email: email.trim(),
      password: password,
      data: {'full_name': fullName.trim()},
      emailRedirectTo: kIsWeb ? Uri.base.origin : AppConfig.appAuthCallback,
    );
    return response.session != null;
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.resetPasswordForEmail(
      email.trim(),

      redirectTo: kIsWeb
          ? '${Uri.base.origin}/reset-password'
          : AppConfig.appAuthCallback,
    );
  }

  Future<void> updatePassword(String newPassword) async {
    await _auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> signOut() => _auth.signOut();
}
