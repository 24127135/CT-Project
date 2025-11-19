import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // NOTE: For Android Emulator, use 10.0.2.2. 
  // If testing on a real phone, use your computer's LAN IP (e.g., 192.168.1.x)
  static const String baseUrl = 'http://10.0.2.2:8000/api/auth';

  // Login Function
  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return true; // OTP sent successfully
      } else {
        print('Login Failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Connection Error: $e');
      return false;
    }
  }

  // Registration Function
  Future<bool> register(String email, String fullName, String password) async {
    final url = Uri.parse('$baseUrl/register/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'full_name': fullName,
          'password': password,
          'password_confirm': password, // Required by your Django Serializer
        }),
      );

      if (response.statusCode == 201) {
        return true; // Registered & OTP sent
      } else {
        print('Register Failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Connection Error: $e');
      return false;
    }
  }

  // Verify OTP Function
  Future<Map<String, dynamic>?> verifyOtp(String email, String otp) async {
    final url = Uri.parse('$baseUrl/verify-otp/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        // Returns the Access & Refresh tokens
        return jsonDecode(response.body); 
      } else {
        print('Verification Failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Connection Error: $e');
      return null;
    }
  }
}