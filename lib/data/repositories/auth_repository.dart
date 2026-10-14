import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase_client.dart';

class AuthRepository {
  GoTrueClient get _auth => supabase.auth;

  User? get currentUser => _auth.currentUser;

  Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithPassword(email: email.trim(), password: password);
  }

  /// Returns `true` when the user is signed in right away, `false` when
  /// Supabase requires them to confirm their email first.
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _auth.signUp(
      email: email.trim(),
      password: password,
      data: {'full_name': fullName.trim()},
      emailRedirectTo: kIsWeb ? Uri.base.origin : null,
    );
    return response.session != null;
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: kIsWeb ? '${Uri.base.origin}/reset-password' : null,
    );
  }

  Future<void> updatePassword(String newPassword) async {
    await _auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> signOut() => _auth.signOut();
}
