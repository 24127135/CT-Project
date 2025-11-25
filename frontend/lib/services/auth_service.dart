import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';
import '../core/supabase_config.dart';

/// Methods supported for verifying email OTPs across SDK versions.
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

/// Centralized auth helper wrapping Supabase client with robust fallbacks.
class AuthService {
  final _client = Supabase.instance.client;

  VerifyMode? _preferredVerifyMode;

  // ------------------
  // Public API
  // ------------------

  /// Register using email + password. Returns the SDK AuthResponse.
  Future<AuthResponse> register(String email, String password) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  /// Attempts to sign in and returns `true` if a client session is established.
  /// Returns `false` when call succeeded but no session was created (e.g. passwordless/OTP path).
  Future<bool> login(String email, String password) async {
    final auth = _client.auth;
    final dynamicAuth = auth as dynamic;

    // Preferred modern API
    try {
      await auth.signInWithPassword(email: email, password: password);
      return _client.auth.currentSession != null;
    } catch (_) {}

    // Older SDK variants / alternate names
    final fallbacks = <Future<void> Function()>[
      () => dynamicAuth.signIn(email: email, password: password),
      () => dynamicAuth.signInWithPassword(email, password),
      () => dynamicAuth.signInWithPassword(email, password),
    ];

    for (final call in fallbacks) {
      try {
        await call();
        return _client.auth.currentSession != null;
      } on NoSuchMethodError {
        // method not present on this SDK - try next
      } catch (_) {
        // network or other error - rethrow to caller
        rethrow;
      }
    }

    // REST fallback (token endpoint)
    return await _restLogin(email, password);
  }

  /// Send an email OTP (passwordless) — Supabase will email a code.
  Future<void> sendEmailOtp(String email) async {
    await _client.auth.signInWithOtp(email: email);
  }

  /// Verify an email OTP code previously sent to `email`.
  /// This uses the SDK where available and falls back to the REST verify endpoint.
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
      // If SDK path failed, try REST as a last resort
      if (mode != VerifyMode.rest) {
        await _verifyEmailOtpRest(email, token);
        return;
      }
      rethrow;
    }
  }

  /// Current session helper
  Session? get currentSession => _client.auth.currentSession;

  /// Sign out
  Future<void> signOut() async => await _client.auth.signOut();

  // ------------------
  // Private helpers
  // ------------------

  Future<bool> _restLogin(String email, String password) async {
    final dio = Dio();
    final endpoint = '$supabaseUrl/auth/v1/token?grant_type=password';
    final headers = {'apikey': supabaseAnonKey, 'Content-Type': 'application/json'};

    final resp = await dio.post(endpoint, data: {'email': email, 'password': password}, options: Options(headers: headers));
    if (resp.statusCode != null && resp.statusCode! >= 200 && resp.statusCode! < 300) {
      // Attempt to populate SDK session when available
      try {
        final data = resp.data as Map<String, dynamic>;
        final access = data['access_token'];
        final refresh = data['refresh_token'];
        try {
          await (_client.auth as dynamic).setSession({'access_token': access, 'refresh_token': refresh});
        } catch (_) {
          // SDK doesn't permit programmatic session set — leave auth to SDK
        }
      } catch (_) {}
      return _client.auth.currentSession != null;
    }
    throw Exception('REST login failed: ${resp.statusCode} ${resp.data}');
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
      } catch (_) {
        return true; // method exists but failed due to other reasons
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
}