import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isGuestMode = true; // Start in guest mode by default

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isGuestMode => _isGuestMode && !isAuthenticated;

  AuthProvider() {
    _user = _supabase.auth.currentUser;
    if (_user != null) {
      _isGuestMode = false;
    }

    _supabase.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      if (_user != null) {
        _isGuestMode = false;
      }
      notifyListeners();
    });
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signUp(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _isGuestMode = false;
        return true;
      } else {
        _errorMessage = 'Failed to create account';
        return false;
      }
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _isGuestMode = false;
        return true;
      } else {
        _errorMessage = 'Invalid credentials';
        return false;
      }
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      _isGuestMode = true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Guest mode - no authentication, just local storage
  void continueAsGuest() {
    _isGuestMode = true;
    _user = null;
    notifyListeners();
  }

  // Check if user needs to login for premium features
  bool requiresLogin() {
    return !isAuthenticated;
  }
}