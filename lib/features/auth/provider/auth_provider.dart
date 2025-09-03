import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  late final StreamSubscription<AuthState> _authSubscription;

  User? _user;
  User? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _user = _repository.getCurrentUser();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      authState,
    ) {
      print('Auth state changed: ${authState.event}');
      print('User: ${authState.session?.user?.email ?? 'No user'}');

      // Update user whenever session changes
      final newUser = authState.session?.user;

      // Only update if user actually changed
      if (_user?.id != newUser?.id) {
        _user = newUser;
        _isLoading = false; // Stop loading when auth state changes
        _errorMessage = null; // Clear any error messages

        print('AuthProvider - User updated: ${_user?.email ?? 'null'}');
        notifyListeners();
      }
    });
  }

  Future<void> signInWithGoogle() async {
    print('AuthProvider - Starting Google sign-in');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.signInWithGoogle();
      print('AuthProvider - Google sign-in initiated');
      // Don't set _isLoading = false here - let the auth state listener handle it
    } catch (e) {
      print('AuthProvider - Google sign-in error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _repository.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _repository.signInWithEmail(
        email: email,
        password: password,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _user = null;
    notifyListeners();
  }

  // Method to manually refresh auth state (useful for debugging)
  void refreshAuthState() {
    _user = _repository.getCurrentUser();
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
