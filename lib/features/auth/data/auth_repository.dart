import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';

class AuthRepository {
  final SupabaseClient _client = SupabaseService.client;

  Future<void> signInWithGoogle() async {
    try {
      print("Starting Google OAuth flow");
      if (kIsWeb) {
        await _client.auth.signInWithOAuth(
          OAuthProvider.google,
          queryParams: const {'prompt': 'select_account'},
        );
      } else {
        await _client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'io.supabase.flutter://login-callback/',
          queryParams: const {'prompt': 'select_account'},
        );
      }

      // Don't return user here - the OAuth flow will complete asynchronously
      // The auth state listener will handle the user update when they return
      print("OAuth flow initiated, waiting for redirect...");
    } catch (e) {
      print("OAuth error: $e");
      throw Exception('Google Sign-In failed: $e');
    }
  }

  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );

      if (response.user != null) {
        return response.user;
      } else {
        throw Exception('Sign up failed: No user returned');
      }
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return response.user;
      } else {
        throw Exception('Sign in failed: No user returned');
      }
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? getCurrentUser() {
    return _client.auth.currentUser;
  }
}
