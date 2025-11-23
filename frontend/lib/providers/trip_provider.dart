import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TripProvider with ChangeNotifier {
  // 1. Lấy IP từ biến môi trường 'SERVER_IP'.
  // Nếu không có (ví dụ quên chạy script), mặc định về localhost của Android (10.0.2.2)

  // 2. Ghép vào chuỗi URL
    // Removed unused server IP constant
  final ApiService _api = ApiService();

  TripProvider([String? unused]);

  // --- DỮ LIỆU ---
  String searchLocation = '';
  String? accommodation;
  String? paxGroup;

  // THAY ĐỔI QUAN TRỌNG Ở ĐÂY: Thêm endDate
  DateTime? startDate;
  DateTime? endDate; // <--- Biến mới để lưu ngày về

  String? difficultyLevel;
  String note = '';
  List<String> selectedInterests = [];
  String tripName = '';

  // --- SETTERS ---

  // Hàm mới: Lưu cả ngày đi và ngày về cùng lúc
  void setTripDates(DateTime start, DateTime end) {
    startDate = start;
    endDate = end;
    notifyListeners();
  }
  void setNote(String value) {
    note = value;
    notifyListeners();
  }

  // Logic tính toán số ngày (Getter)
  // Ví dụ: Đi 19 về 20 => 20 - 19 = 1 ngày + 1 = 2 ngày
  int get durationDays {
    if (startDate == null || endDate == null) return 1; // Mặc định 1 ngày
    return endDate!.difference(startDate!).inDays + 1;
  }

  // ... (Giữ nguyên các setter khác: setSearchLocation, setAccommodation, etc.) ...
  void setSearchLocation(String value) {
    searchLocation = value;
    notifyListeners();
  }
  void setAccommodation(String value) {
    accommodation = value;
    notifyListeners();
  }
  void setPaxGroup(String value) {
    paxGroup = value;
    notifyListeners();
  }
  void setDifficultyLevel(String value) {
    difficultyLevel = value;
    notifyListeners();
  }
  void toggleInterest(String interest) {
    if (selectedInterests.contains(interest)) {
      selectedInterests.remove(interest);
    } else {
      selectedInterests.add(interest);
    }
    notifyListeners();
  }
  void setTripName(String value) {
    tripName = value;
    notifyListeners();
  }

  // Helpers
  int get parsedGroupSize {
    if (paxGroup == 'Đơn lẻ (1-2 người)') return 2;
    if (paxGroup == 'Nhóm nhỏ (3-6 người)') return 5;
    if (paxGroup == 'Nhóm đông (7+ người)') return 8;
    return 1;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return DateTime.now().toIso8601String().split('T')[0];
    return date.toIso8601String().split('T')[0];
  }

  // API 1: Gợi ý Route (Giữ nguyên)
  Future<List<dynamic>> fetchSuggestedRoutes() async {
    final Map<String, dynamic> queryParams = {
      'location': searchLocation,
      'difficulty': difficultyLevel ?? '',
    };
    for (var interest in selectedInterests) {
      (queryParams['interests'] ??= []).add(interest);
    }

    // Convert list params to repeated query params or comma-separated values depending on backend expectations
    final qp = <String, dynamic>{};
    queryParams.forEach((k, v) {
      if (v is List) qp[k] = v.map((e) => e.toString()).toList();
      else qp[k] = v.toString();
    });

    final res = await _api.fetchSuggestedRoutes(qp);
    return res;
  }

  // API 2: Lưu Mẫu (Cập nhật durationDays)
  Future<void> saveHistoryInput(String templateName) async {
    final Map<String, dynamic> body = {
      'templateName': templateName,
      'location': searchLocation,
      'restType': accommodation ?? '',
      'groupSize': parsedGroupSize,
      'startDate': _formatDate(startDate),
      'durationDays': durationDays, // <--- GỬI SỐ NGÀY ĐÃ TÍNH
      'difficulty': difficultyLevel ?? '',
      'personalInterest': selectedInterests,
    };

    await _api.saveHistoryInput(body);
  }

  // API 3: Tạo Plan (Cập nhật durationDays)
  Future<dynamic> createPlan({required int routeId}) async {
    final Map<String, dynamic> body = {
      'name': tripName,
      'route': routeId,
      'location': searchLocation,
      'restType': accommodation ?? '',
      'groupSize': parsedGroupSize,
      'startDate': _formatDate(startDate),
      'durationDays': durationDays, // <--- GỬI SỐ NGÀY ĐÃ TÍNH
      'difficulty': difficultyLevel ?? '',
      'personalInterest': selectedInterests,
    };

    final created = await _api.createPlan(body);
    return created;
  }
}