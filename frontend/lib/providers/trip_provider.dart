import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TripProvider with ChangeNotifier {
  // 1. Lấy IP từ biến môi trường 'SERVER_IP'.
  // Nếu không có (ví dụ quên chạy script), mặc định về localhost của Android (10.0.2.2)
  static const String _serverIp = String.fromEnvironment(
      'SERVER_IP',
      defaultValue: '10.0.2.2'
  );

  // 2. Ghép vào chuỗi URL
  static const String _baseUrl = 'http://$_serverIp:8000/api';
  final String _jwtToken;

  TripProvider(this._jwtToken);

  Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    //'Authorization': 'Bearer $_jwtToken',
  };

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

    final uri = Uri.parse('$_baseUrl/routes/suggested/').replace(
      queryParameters: queryParams.map((key, value) {
        if (value is List) return MapEntry(key, value.map((e) => e.toString()).toList());
        return MapEntry(key, value.toString());
      }),
    );

    final response = await http.get(uri, headers: _authHeaders);
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('Lỗi tải lộ trình: ${response.statusCode}');
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

    final response = await http.post(
      Uri.parse('$_baseUrl/history-inputs/'),
      headers: _authHeaders,
      body: json.encode(body),
    );

    if (response.statusCode != 201) {
      throw Exception('Lỗi lưu mẫu: ${response.body}');
    }
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

    final response = await http.post(
      Uri.parse('$_baseUrl/plans/'),
      headers: _authHeaders,
      body: json.encode(body),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Lỗi tạo Plan: ${response.body}');
    }
  }
}