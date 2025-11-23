import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';
import '../core/supabase_config.dart';

enum VerifyMode {
  unknown,
  verifyOtpNamed,
  verifyOtpPositional,
  verifyOtpTokenFirst,
  verifyOtpTokenNamed,
  verifyOtpEnum,
  confirmOtpNamed,
  signInWithOtpPositional,
  signInWithOtpNamed,
  rest
}

class AuthService {
  final _client = Supabase.instance.client;

  /// Sign up using email & password via Supabase Auth
  Future<AuthResponse> register(String email, String password) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  /// Sign in using email & password
  ///
  /// Tries several SDK signatures (older/newer) and falls back to the REST
  /// token endpoint if needed. On success this will leave the Supabase client
  /// session populated when possible; callers should listen to auth state.
  /// Attempts to sign in and returns `true` if a client session is established.
  /// Returns `false` when the call succeeded but no session was created (e.g. passwordless/OTP sent).
  Future<bool> login(String email, String password) async {
    final auth = _client.auth;
    final dynamicAuth = auth as dynamic;

    // Try the modern named signature first
    try {
      await auth.signInWithPassword(email: email, password: password);
      // If SDK populated the session, return true
      return _client.auth.currentSession != null;
    } catch (e) {
      // Continue to fallbacks
    }

    // Try several possible older/alternate SDK signatures
    try {
      // Common older API
      await dynamicAuth.signIn(email: email, password: password);
      return _client.auth.currentSession != null;
    } on NoSuchMethodError catch (_) {}
    catch (_) {}

    try {
      // Some variants expose a positional signInWithPassword
      await dynamicAuth.signInWithPassword(email, password);
      return _client.auth.currentSession != null;
    } on NoSuchMethodError catch (_) {}
    catch (_) {}

    try {
      // `signInWithPassword` positional
      await dynamicAuth.signInWithPassword(email, password);
      return _client.auth.currentSession != null;
    } on NoSuchMethodError catch (_) {}
    catch (_) {}

    // REST fallback: call /auth/v1/token with grant_type=password
    try {
      final dio = Dio();
      final endpoint = '$supabaseUrl/auth/v1/token?grant_type=password';
      final headers = {'apikey': supabaseAnonKey, 'Content-Type': 'application/json'};
      final resp = await dio.post(endpoint, data: {'email': email, 'password': password}, options: Options(headers: headers));
      if (resp.statusCode != null && resp.statusCode! >= 200 && resp.statusCode! < 300) {
        // Try to set session on client if possible
        try {
          final data = resp.data as Map<String, dynamic>;
          final access = data['access_token'];
          final refresh = data['refresh_token'];
          // Some SDKs expose setSession or setAuth to populate client state
          try {
            await (auth as dynamic).setSession({'access_token': access, 'refresh_token': refresh});
          } catch (_) {
            // ignore if SDK doesn't have it; auth state may not be populated
          }
        } catch (_) {}
        return _client.auth.currentSession != null;
      }
      throw Exception('REST login failed: ${resp.statusCode} ${resp.data}');
    } catch (e) {
      rethrow;
    }
  }

  /// Send a magic link / email OTP to the provided email
  /// Send an email OTP (one-time code) to the provided email
  Future<void> sendEmailOtp(String email) async {
    // Do not provide an email redirect so Supabase sends an OTP code instead of a magic link
    await _client.auth.signInWithOtp(email: email);
  }

  /// Verify an email OTP code previously sent to `email`.
  ///
  /// Different `supabase_flutter` versions expose different methods for
  /// verifying OTPs. This method tries a few call signatures dynamically
  /// and completes successfully if any of them succeeds. It throws on
  /// failure so callers can handle the error.
  VerifyMode? _preferredVerifyMode;

  Future<VerifyMode> _determinePreferredMode() async {
    if (_preferredVerifyMode != null && _preferredVerifyMode != VerifyMode.unknown) {
      return _preferredVerifyMode!;
    }

    final auth = _client.auth;
    final dynamicAuth = auth as dynamic;

    const probeEmail = 'probe@example.com';
    const probeToken = '000000';

    Future<bool> probe(Future<dynamic> Function() call) async {
      try {
        await call();
        return true;
      } on NoSuchMethodError catch (_) {
        return false;
      } catch (e) {
        return true;
      }
    }

    if (await probe(() => dynamicAuth.verifyOtp(probeEmail, probeToken, 'email'))) {
      _preferredVerifyMode = VerifyMode.verifyOtpPositional;
      return _preferredVerifyMode!;
    }
    if (await probe(() => dynamicAuth.verifyOtp(email: probeEmail, token: probeToken, type: 'email'))) {
      _preferredVerifyMode = VerifyMode.verifyOtpNamed;
      return _preferredVerifyMode!;
    }
    if (await probe(() => dynamicAuth.verifyOTP(probeToken, 'email'))) {
      _preferredVerifyMode = VerifyMode.verifyOtpPositional;
      return _preferredVerifyMode!;
    }
    if (await probe(() => dynamicAuth.verifyOtp(probeToken, 'email'))) {
      _preferredVerifyMode = VerifyMode.verifyOtpTokenFirst;
      return _preferredVerifyMode!;
    }
    if (await probe(() => dynamicAuth.verifyOtp(token: probeToken, type: 'email'))) {
      _preferredVerifyMode = VerifyMode.verifyOtpTokenNamed;
      return _preferredVerifyMode!;
    }
    if (await probe(() => dynamicAuth.verifyOtp(token: probeToken, type: OtpType.email))) {
      _preferredVerifyMode = VerifyMode.verifyOtpEnum;
      return _preferredVerifyMode!;
    }
    if (await probe(() => dynamicAuth.confirmOtp(email: probeEmail, token: probeToken))) {
      _preferredVerifyMode = VerifyMode.confirmOtpNamed;
      return _preferredVerifyMode!;
    }
    if (await probe(() => dynamicAuth.signInWithOtp(probeEmail, probeToken))) {
      _preferredVerifyMode = VerifyMode.signInWithOtpPositional;
      return _preferredVerifyMode!;
    }
    if (await probe(() => dynamicAuth.signInWithOtp(email: probeEmail, token: probeToken))) {
      _preferredVerifyMode = VerifyMode.signInWithOtpNamed;
      return _preferredVerifyMode!;
    }

    _preferredVerifyMode = VerifyMode.rest;
    return _preferredVerifyMode!;
  }

  Future<void> verifyEmailOtp(String email, String token) async {
    final mode = await _determinePreferredMode();
    final auth = _client.auth;
    final dynamicAuth = auth as dynamic;

    try {
      switch (mode) {
        case VerifyMode.verifyOtpPositional:
          await dynamicAuth.verifyOtp(email, token, 'email');
          return;
        case VerifyMode.verifyOtpNamed:
          await dynamicAuth.verifyOtp(email: email, token: token, type: 'email');
          return;
        case VerifyMode.verifyOtpTokenFirst:
          await dynamicAuth.verifyOtp(token, 'email');
          return;
        case VerifyMode.verifyOtpTokenNamed:
          await dynamicAuth.verifyOtp(token: token, type: 'email');
          return;
        case VerifyMode.verifyOtpEnum:
          await dynamicAuth.verifyOtp(token: token, type: OtpType.email);
          return;
        case VerifyMode.confirmOtpNamed:
          await dynamicAuth.confirmOtp(email: email, token: token);
          return;
        case VerifyMode.signInWithOtpPositional:
          await dynamicAuth.signInWithOtp(email, token);
          return;
        case VerifyMode.signInWithOtpNamed:
          await dynamicAuth.signInWithOtp(email: email, token: token);
          return;
        case VerifyMode.rest:
          await _verifyEmailOtpRest(email, token);
          return;
        default:
          await _verifyEmailOtpRest(email, token);
          return;
      }
    } catch (e) {
      if (mode != VerifyMode.rest) {
        try {
          await _verifyEmailOtpRest(email, token);
          return;
        } catch (_) {
        }
      }
      rethrow;
    }
  }

  Future<void> _verifyEmailOtpRest(String email, String token) async {
    final dio = Dio();
    final endpoint = '$supabaseUrl/auth/v1/verify';
    final headers = {
      'apikey': supabaseAnonKey,
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final body = {'email': email, 'token': token, 'type': 'email'};

    final resp = await dio.post(endpoint, data: body, options: Options(headers: headers));
    if (resp.statusCode != null && (resp.statusCode! >= 200 && resp.statusCode! < 300)) {
      return;
    }
    throw Exception('REST verify failed: ${resp.statusCode} ${resp.data}');
  }

  /// Get current session (managed by Supabase client)
  Session? get currentSession => _client.auth.currentSession;

  /// Sign out
  Future<void> signOut() async => await _client.auth.signOut();
}