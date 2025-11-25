import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  // Base URL of your Django backend
  static const String _baseUrl = 'http://192.168.0.12:8000';

  final Dio _dio = Dio(BaseOptions(baseUrl: _baseUrl));

  ApiService() {
    // Attach interceptor to add Authorization header from Supabase session
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final session = Supabase.instance.client.auth.currentSession;
          final token = session?.accessToken;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (_) {
          // ignore
        }
        return handler.next(options);
      },
      onError: (err, handler) async {
        // If unauthorized, try to get a refreshed token from Supabase and retry once
        if (err.response?.statusCode == 401) {
          try {
            final session = Supabase.instance.client.auth.currentSession;
            final token = session?.accessToken;
            if (token != null) {
              final opts = err.requestOptions;
              opts.headers['Authorization'] = 'Bearer $token';
              final cloneReq = await _dio.fetch(opts);
              return handler.resolve(cloneReq);
            }
          } catch (_) {
            // ignore retry errors
          }
        }
        return handler.next(err);
      },
    ));
  }

  // Register (keeps calling backend endpoint; backend may or may not be used once you migrate fully to Supabase)
  Future<bool> register({
    required String email,
    required String fullName,
    required String password,
  }) async {
    try {
      await _dio.post(
        '/api/users/register/',
        data: {
          'email': email,
          'full_name': fullName,
          'password': password,
          'password_confirm': password,
        },
      );
      return true;
    } on DioException catch (e) {
      print('Register error: ${e.response?.data}');
      return false;
    } catch (e) {
      print('Unknown register error: $e');
      return false;
    }
  }

  // Login (if you keep server-side login) — note: with Supabase auth you may not need this
  Future<bool> login({required String email, required String password}) async {
    try {
      final response = await _dio.post(
        '/api/token/',
        data: {'email': email, 'password': password},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      print('Login error: ${e.response?.data}');
      return false;
    } catch (e) {
      print('Unknown login error: $e');
      return false;
    }
  }

  // Logout via Supabase
  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
  }

  // Fetch suggested routes from backend with query parameters
  Future<List<dynamic>> fetchSuggestedRoutes(Map<String, dynamic> queryParams) async {
    try {
      final response = await _dio.get('/api/routes/suggested/', queryParameters: queryParams);
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      print('fetchSuggestedRoutes error: ${e.response?.data}');
      rethrow;
    }
  }

  // Save history input template
  Future<void> saveHistoryInput(Map<String, dynamic> body) async {
    try {
      await _dio.post('/api/history-inputs/', data: body);
    } on DioException catch (e) {
      print('saveHistoryInput error: ${e.response?.data}');
      rethrow;
    }
  }

  // Create plan
  Future<dynamic> createPlan(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post('/api/plans/', data: body);
      return response.data;
    } on DioException catch (e) {
      print('createPlan error: ${e.response?.data}');
      rethrow;
    }
  }
}