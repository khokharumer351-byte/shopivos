import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/profile.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/profile_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    AuthRepository? authRepository,
    ProfileRepository? profileRepository,
  }) : _auth = authRepository ?? AuthRepository(),
       _profiles = profileRepository ?? ProfileRepository() {
    _user = _auth.currentUser;
    if (_user != null) _loadProfile();
    _subscription = _auth.onAuthStateChange.listen(_onAuthStateChange);
  }

  final AuthRepository _auth;
  final ProfileRepository _profiles;
  StreamSubscription<AuthState>? _subscription;

  User? _user;
  Profile? _profile;
  bool _profileLoading = false;
  bool _isPasswordRecovery = false;

  User? get user => _user;
  Profile? get profile => _profile;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _profile?.isAdmin ?? false;
  bool get profileLoading => _profileLoading;

  bool get isPasswordRecovery => _isPasswordRecovery;

  void _onAuthStateChange(AuthState state) {
    final previousId = _user?.id;
    _user = state.session?.user;

    if (state.event == AuthChangeEvent.passwordRecovery) {
      _isPasswordRecovery = true;
    }
    if (_user == null) {
      _profile = null;
      _isPasswordRecovery = false;
    } else if (_user!.id != previousId ||
        (_profile == null && !_profileLoading)) {
      _loadProfile();
    }
    notifyListeners();
  }

  Future<void> _loadProfile() async {
    final userId = _user?.id;
    if (userId == null) return;
    _profileLoading = true;
    notifyListeners();
    try {
      final profile = await _profiles.fetch(userId);
      if (_user?.id == userId) _profile = profile;
    } catch (e) {
      debugPrint('Failed to load profile: $e');
    } finally {
      _profileLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProfile() => _loadProfile();

  Future<void> signIn(String email, String password) =>
      _auth.signIn(email: email, password: password);

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) => _auth.signUp(email: email, password: password, fullName: fullName);

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordReset(email);

  Future<void> updatePassword(String newPassword) async {
    await _auth.updatePassword(newPassword);
    _isPasswordRecovery = false;
    notifyListeners();
  }

  Future<void> updateProfile(Profile profile) async {
    _profile = await _profiles.update(profile);
    notifyListeners();
  }

  Future<void> signOut() => _auth.signOut();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
