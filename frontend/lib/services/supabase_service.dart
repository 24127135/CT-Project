import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  // Sign up by email+password
  Future<AuthResponse> signUp(String email, String password) =>
      _client.auth.signUp(email: email, password: password);

  // Sign in
  Future<AuthResponse> signIn(String email, String password) =>
      _client.auth.signInWithPassword(email: email, password: password);

  // Sign out
  Future<void> signOut() => _client.auth.signOut();

  // Access current user session
  Session? get session => _client.auth.currentSession;

  // Example: send OTP (magic link) or email OTP (Supabase supports OTP/magic links)
    Future<void> signInWithOtp(String email) =>
            // Send an email OTP (no redirect) so Supabase issues a 4-digit code the user
            // can enter in-app.
          // Send an email OTP (no redirect) so Supabase will send an in-email OTP code (not a browser link).
          // Note: Supabase OTP length is controlled by project settings; this app accepts 6-digit codes.
          _client.auth.signInWithOtp(email: email);
}