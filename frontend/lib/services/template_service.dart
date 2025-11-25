import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';
import '../models/trip_template.dart';

class TemplateService {
  // ---------------------------------------------------------
  // BƯỚC 1: CẤU HÌNH IP
  // Nếu chạy máy ảo Android: dùng 10.0.2.2
  // Nếu chạy máy thật: dùng IP máy tính (VD: 192.168.1.12)
  // ---------------------------------------------------------
  static const String _serverIp = '10.0.2.2'; // Đổi thành IP LAN nếu chạy máy thật
  static const String baseUrl = 'http://$_serverIp:8000/api/auth/templates/';
  // LƯU Ý: Kiểm tra lại xem backend của bạn là 'api/auth/templates/'
  // hay là 'api/templates/' hay 'api/history-inputs/'?

  final TokenService _tokenService = TokenService();

  // 1. GET: Lấy danh sách mẫu
  Future<List<TripTemplate>> getTemplates() async {
    final token = await _tokenService.getToken();
    print("==== TOKEN ====");
    print(token);
    // Debug log
    print("GET Templates - Token: ${token != null ? 'Có' : 'Không'}");
    if (token == null) return [];

    try {
      print("Đang gọi API: $baseUrl");
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Response Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        // Fix lỗi charset nếu bị lỗi font tiếng Việt
        String responseBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = jsonDecode(responseBody);
        return data.map((json) => TripTemplate.fromJson(json)).toList();
      } else {
        print('Lỗi Server: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Lỗi kết nối (GET): $e');
      return [];
    }
  }

  // 2. POST: Lưu mẫu mới
  Future<bool> saveTemplate(Map<String, dynamic> templateData) async {
    final token = await _tokenService.getToken();

    if (token == null) {
      print("Lỗi: Chưa đăng nhập (Token null)");
      return false;
    }

    try {
      print("Đang POST tới: $baseUrl");
      print("Dữ liệu gửi đi: ${jsonEncode(templateData)}");

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(templateData),
      );

      print("POST Status Code: ${response.statusCode}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("✅ Lưu thành công!");
        return true;
      } else {
        // In chi tiết lỗi từ Backend
        print("❌ Lưu thất bại. Server phản hồi: ${response.body}");

        // Thử throw exception để UI hiện thông báo
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        if (errorData is Map && errorData['name'] != null) {
          throw Exception("Tên mẫu này đã tồn tại, vui lòng chọn tên khác.");
        }
        throw Exception('Lỗi Server: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Lỗi kết nối (POST): $e');
      rethrow;
    }
  }
}