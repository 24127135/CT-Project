import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../features/preference_matching/models/route_model.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  // ⚠️ THAY KEY CỦA BẠN VÀO ĐÂY
  static const String _apiKey = 'AIzaSyAFhSGCwB4b7l4rvGpSAM75XHToJwIWA74';

  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-flash-latest', // Bản Flash nhanh và miễn phí
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json', // Yêu cầu trả về JSON chuẩn
        temperature: 0.7, // Độ sáng tạo vừa phải
      ),
    );
  }
  Future<void> checkAvailableModels() async {
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$_apiKey');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("📋 DANH SÁCH MODEL KHẢ DỤNG:");
        for (var m in data['models']) {
          // Chỉ in ra các model hỗ trợ generateContent
          if (m['supportedGenerationMethods'].contains('generateContent')) {
            debugPrint("   - ${m['name']}");
          }
        }
      } else {
        debugPrint("❌ Lỗi kiểm tra model: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Lỗi kết nối: $e");
    }
  }
  /// Hàm chính: Gửi danh sách Route + User Info cho AI xử lý
  Future<List<RouteModel>> recommendRoutes({
    required List<RouteModel> allRoutes,
    required String userLocation,
    required String userInterests,
    required String userExperience,
    required String duration,
    required String groupSize,
  }) async {
    // 1. Tối ưu dữ liệu gửi đi (Chỉ gửi thông tin cần thiết để tiết kiệm token)
    // AI không cần biết URL ảnh hay tọa độ chi tiết lúc này
    final routesJson = allRoutes.map((r) => {
      "id": r.id,
      "name": r.name,
      "location": r.location,
      "description": r.description,
      "difficulty": r.elevationGainM > 1000 ? "Khó" : "Dễ",
      "terrain": r.terrain,
    }).toList();

    // 2. Soạn Prompt (Kịch bản cho AI)
    final prompt = '''
      Bạn là chuyên gia tư vấn du lịch Trekking tại Việt Nam. 
      
      HỒ SƠ NGƯỜI DÙNG:
      - Muốn đi: $userLocation (nếu rỗng là đi đâu cũng được)
      - Kinh nghiệm: $userExperience
      - Thời gian: $duration
      - Nhóm: $groupSize
      - Sở thích/Yêu cầu: $userInterests

      DANH SÁCH CUNG ĐƯỜNG HIỆN CÓ (JSON):
      ${jsonEncode(routesJson)}

      NHIỆM VỤ:
      1. Chọn ra tối đa 5 cung đường phù hợp nhất.
      2. Viết một đoạn "ai_reason" (khoảng 2 câu) thật ngắn gọn, súc tích, giải thích tại sao cung này hợp với họ (xưng "bạn").
      3. Nếu người dùng thích "Săn mây", ưu tiên cung cao. Nếu thích "Suối/Thác", ưu tiên cung có nước.

      TRẢ VỀ KẾT QUẢ DẠNG JSON MẢNG (Array):
      [
        {
          "id": 123,
          "ai_reason": "Cung này hợp vì..."
        }
      ]
    ''';

    try {
      debugPrint("🤖 Đang gửi yêu cầu cho Gemini...");
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null) return [];

      // 3. Parse kết quả trả về
      final List<dynamic> aiResults = jsonDecode(response.text!);
      debugPrint("🤖 Gemini trả về ${aiResults.length} gợi ý.");

      // 4. Map ngược lại vào danh sách RouteModel gốc
      List<RouteModel> recommendedRoutes = [];

      for (var item in aiResults) {
        final int id = item['id'];
        final String reason = item['ai_reason']; // Text Gemini trả về

        try {
          final originalRoute = allRoutes.firstWhere((r) => r.id == id);

          recommendedRoutes.add(originalRoute.copyWith(matchReason: reason));

        } catch (e) {
          continue;
        }
      }
      return recommendedRoutes;

    } catch (e) {
      debugPrint("❌ Lỗi Gemini: $e");
      // Nếu AI lỗi (mất mạng, hết quota...), trả về 5 cung đầu tiên của danh sách gốc (Fallback)
      return allRoutes.take(5).toList();
    }
  }
}