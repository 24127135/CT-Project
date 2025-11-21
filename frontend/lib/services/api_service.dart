import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // 1. ĐỊA CHỈ IP CỦA BACKEND DJANGO
  //    Hãy đảm bảo đây là IP mạng của máy tính chạy server Django.
  //    KHÔNG dùng 'localhost' hay '127.0.0.1'
  static const String _baseUrl = 'http://192.168.0.12:8000';

  // 2. TẠO CÁC BIẾN CẦN THIẾT
  final Dio _dio = Dio(BaseOptions(baseUrl: _baseUrl));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // 3. HÀM ĐĂNG KÝ (REGISTER)
  Future<bool> register({
    required String email,
    required String fullName,
    required String password,
  }) async {
    try {
      // Gửi yêu cầu POST đến API Đăng ký
      await _dio.post(
        '/api/users/register/', // Đường dẫn API
        data: {
          'email': email,
          'full_name': fullName, // Giống hệt key trong Django Serializer
          'password': password,
          'password_confirm': password, // Giả sử pass và confirm giống nhau
        },
      );
      
      // Nếu không có lỗi, đăng ký thành công
      print('Đăng ký thành công');
      return true;

    } on DioException catch (e) {
      // Xử lý lỗi
      print('Lỗi khi đăng ký: ${e.response?.data}');
      return false;
    } catch (e) {
      print('Lỗi không xác định: $e');
      return false;
    }
  }

  // 4. HÀM ĐĂNG NHẬP (LOGIN)
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      // Gửi yêu cầu POST đến API Lấy Token
      final response = await _dio.post(
        '/api/token/', // Đường dẫn API của Simple JWT
        data: {
          'email': email,
          'password': password,
        },
      );

      // Nếu thành công (status 200 OK)
      if (response.statusCode == 200) {
        // Lấy access và refresh token từ JSON trả về
        final String accessToken = response.data['access'];
        final String refreshToken = response.data['refresh'];

        // Lưu token vào Secure Storage
        await _storage.write(key: 'access_token', value: accessToken);
        await _storage.write(key: 'refresh_token', value: refreshToken);
        
        print('Đăng nhập thành công, token đã được lưu.');
        return true;
      }
      return false;

    } on DioException catch (e) {
      // Xử lý lỗi (ví dụ: sai mật khẩu)
      print('Lỗi khi đăng nhập: ${e.response?.data}');
      return false;
    } catch (e) {
      print('Lỗi không xác định: $e');
      return false;
    }
  }

  // 5. HÀM LẤY TOKEN (ĐỂ GỌI API ĐÃ XÁC THỰC)
  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  // 6. HÀM ĐĂNG XUẤT (LOGOUT)
  Future<void> logout() async {
    // Xóa token khỏi storage
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    print('Đã đăng xuất.');
  }
}