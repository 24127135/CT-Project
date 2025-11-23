import 'package:supabase_flutter/supabase_flutter.dart';

/// TokenService is now a thin adapter around Supabase session management.
class TokenService {
  /// Returns the current access token from Supabase session, or null.
  Future<String?> getToken() async {
    final session = Supabase.instance.client.auth.currentSession;
    return session?.accessToken;
  }

  /// Clear token / sign out via Supabase
  Future<void> clearToken() async {
    await Supabase.instance.client.auth.signOut();
  }

  /// Deprecated: saving tokens is managed by the Supabase client.
  Future<void> saveToken(String token) async {
    // Supabase client persists sessions automatically; no-op kept for compatibility.
    return;
  }
}