import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../features/preference_matching/models/route_model.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  // ⚠️ THAY KEY CỦA BẠN VÀO ĐÂY
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
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

  /// Generates the PEC (Personalized Equipment Checklist)
  /// Returns a Map where keys are Categories (String) and values are Lists of items with IDs
  Future<Map<String, dynamic>> generateChecklist({
    required RouteModel route, // Information about the route
    required Map<String, dynamic> userProfile, // User info (interests, experience, etc.)
    required List<Map<String, dynamic>> allEquipment, // The full catalog from Supabase
  }) async {
    // 1. Optimize Equipment Data (Send only ID, Name, Category to save tokens)
    final catalogSummary = allEquipment.map((e) => {
      "id": e['id'],
      "name": e['name'],
      "category": e['category'],
    }).toList();

    // 2. Create the Prompt
    final prompt = '''
      You are a trekking expert. Create a personalized packing list for this trip.

      TRIP DETAILS:
      - Location: ${route.name} (${route.location})
      - Terrain: ${route.terrain}
      - Duration: ${route.durationDays} days
      - User Experience: ${userProfile['difficulty']}
      - Group Size: ${userProfile['group_size']}
      - Interests: ${userProfile['interests']}

      AVAILABLE EQUIPMENT CATALOG (JSON):
      ${jsonEncode(catalogSummary)}

      TASK:
      Select specific items from the catalog that are essential for this specific trip.
      
      RULES:
      1. Return a JSON object where keys are the exact Category names from the catalog.
      2. Values should be a list of objects containing:
         - "id": The exact ID from the catalog (Int/String).
         - "quantity": Recommended quantity (Int).
         - "reason": A short reason in Vietnamese (String).
      3. Do NOT invent items. Only use IDs from the catalog.

      EXAMPLE OUTPUT FORMAT:
      {
        "Quần áo": [
          {"id": 10, "quantity": 2, "reason": "Chống thấm vì trời mưa"}
        ]
      }
    ''';

    try {
      debugPrint("🤖 Gemini: Generating checklist...");
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null) return {};

      // Clean Markdown if Gemini adds it (```json ... ```)
      String cleanJson = response.text!.replaceAll(RegExp(r'^```json|```$'), '').trim();
      
      // 🟢 ADD THIS LINE TO SEE THE RAW JSON STRING
      debugPrint("🔍 [GEMINI RAW OUTPUT]: $cleanJson"); 

      final Map<String, dynamic> result = jsonDecode(cleanJson);
      
      debugPrint("🤖 Gemini: Generated ${result.length} categories.");
      return result;

    } catch (e) {
      debugPrint("❌ Gemini Error: $e");
      return {}; // Return empty map on failure so app doesn't crash
    }
  }

  Future<String> generateRouteNote(String routeName, String? location) async {
    final locStr = location != null ? "tại $location" : "";
    
    final prompt = '''
      Bạn là chuyên gia du lịch mạo hiểm. Hãy viết một ghi chú ngắn gọn (khoảng 3-4 câu) về cung đường trekking: "$routeName" $locStr.
      
      Nội dung cần bao gồm 3 ý chính:
      1. Địa hình chung (dốc, bằng phẳng, rừng rậm, hay núi đá...).
      2. Thời tiết điển hình cần lưu ý.
      3. Một lưu ý đặc biệt quan trọng cho người đi cung này.

      Vui lòng trả về dưới dạng văn bản liền mạch hoặc gạch đầu dòng, giọng văn hữu ích, cảnh báo an toàn nếu cần. Không cần tiêu đề.
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? "Không thể tạo ghi chú AI lúc này.";
    } catch (e) {
      debugPrint("❌ Gemini Error (Route Note): $e");
      return "Chưa có thông tin AI cho cung đường này.";
    }
  }
}