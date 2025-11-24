import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Import các model và service của bạn
import '../models/trip_template.dart';
import '../services/template_service.dart';

class TripProvider with ChangeNotifier {
  // --- CẤU HÌNH & SERVICES ---

  // 1. Cấu hình IP (Dùng 10.0.2.2 cho máy ảo Android, hoặc IP LAN cho máy thật)
  static const String _serverIp = String.fromEnvironment(
      'SERVER_IP',
      defaultValue: '10.0.2.2'
  );

  static const String _baseUrl = 'http://$_serverIp:8000/api';

  final String _jwtToken;
  final TemplateService _templateService = TemplateService();

  // Constructor yêu cầu JWT (có thể truyền rỗng '' ở main.dart để test)
  TripProvider(this._jwtToken);

  Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    // 'Authorization': 'Bearer $_jwtToken', // Mở comment khi có auth thật
  };

  // --- KHAI BÁO BIẾN STATE (Private) ---
  String _searchLocation = '';
  String? _accommodation;
  String? _paxGroup;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _difficultyLevel;
  String _note = '';
  List<String> _selectedInterests = [];
  String _tripName = '';

  // --- GETTERS (Để UI đọc dữ liệu) ---
  String get searchLocation => _searchLocation;
  String? get accommodation => _accommodation;
  String? get paxGroup => _paxGroup;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String? get difficultyLevel => _difficultyLevel;
  String get note => _note;
  List<String> get selectedInterests => _selectedInterests;
  String get tripName => _tripName;

  // Logic: Tính tổng số ngày
  int get durationDays {
    if (_startDate == null || _endDate == null) return 1;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  // Logic: Chuyển đổi nhóm người sang số nguyên cho Backend
  int get parsedGroupSize {
    if (_paxGroup == 'Đơn lẻ (1-2 người)') return 2;
    if (_paxGroup == 'Nhóm nhỏ (3-6 người)') return 5;
    if (_paxGroup == 'Nhóm đông (7+ người)') return 8;
    return 1;
  }

  // --- SETTERS (Để UI cập nhật dữ liệu) ---
  void setSearchLocation(String value) { _searchLocation = value; notifyListeners(); }
  void setAccommodation(String value) { _accommodation = value; notifyListeners(); }
  void setPaxGroup(String value) { _paxGroup = value; notifyListeners(); }
  void setDifficultyLevel(String value) { _difficultyLevel = value; notifyListeners(); }
  void setNote(String value) { _note = value; notifyListeners(); }
  void setTripName(String value) { _tripName = value; notifyListeners(); }

  void setTripDates(DateTime start, DateTime end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  void toggleInterest(String interest) {
    if (_selectedInterests.contains(interest)) {
      _selectedInterests.remove(interest);
    } else {
      _selectedInterests.add(interest);
    }
    notifyListeners();
  }

  // --- CÁC HÀM HỖ TRỢ ---

  String _formatDate(DateTime? date) {
    if (date == null) return DateTime.now().toIso8601String().split('T')[0];
    return date.toIso8601String().split('T')[0];
  }

  // Hàm Reset (Dọn dẹp form)
  void resetTrip() {
    _searchLocation = '';
    _accommodation = null;
    _paxGroup = null;
    _startDate = null;
    _endDate = null;
    _difficultyLevel = null;
    _note = '';
    _selectedInterests = [];
    _tripName = '';
    notifyListeners();
  }

  // --- TÍNH NĂNG: APPLY TEMPLATE (Fast Input) ---
  void applyTemplate(TripTemplate template) {
    _searchLocation = template.location;
    _accommodation = template.accommodation;
    _paxGroup = template.paxGroup;
    _difficultyLevel = template.difficulty;
    _note = template.note;
    _selectedInterests = List.from(template.interests);
    _tripName = template.name;

    // Logic ngày: Bắt đầu ngày mai, kết thúc theo thời lượng template
    final now = DateTime.now();
    _startDate = now.add(const Duration(days: 1));
    _endDate = _startDate!.add(Duration(days: template.durationDays - 1));

    notifyListeners();
  }

  // --- API CALLS ---

  // 1. Fetch Suggested Routes (HYBRID: Thật -> Fallback sang Giả)
  Future<List<dynamic>> fetchSuggestedRoutes() async {
    // Tạo Query Params
    final Map<String, dynamic> queryParams = {
      'location': _searchLocation,
      'difficulty': _difficultyLevel ?? '',
    };
    for (var interest in _selectedInterests) {
      (queryParams['interests'] ??= []).add(interest);
    }

    try {
      // BƯỚC 1: Thử gọi Server thật
      // (Nếu bạn chưa chạy server, dòng này sẽ throw exception và nhảy xuống catch)
      final uri = Uri.parse('$_baseUrl/routes/suggested/').replace(
        queryParameters: queryParams.map((key, value) {
          if (value is List) return MapEntry(key, value.map((e) => e.toString()).toList());
          return MapEntry(key, value.toString());
        }),
      );

      // Timeout ngắn (3s) để nếu lỗi thì chuyển sang mock nhanh
      final response = await http.get(uri, headers: _authHeaders).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }

    } catch (e) {
      // BƯỚC 2: FALLBACK - Dùng Mock Data nếu server lỗi/chưa chạy
      // Giả lập delay mạng cho thật
      await Future.delayed(const Duration(seconds: 1));
      print("⚠️ Lỗi kết nối Server ($e). Đang dùng Mock Data...");

      // Dữ liệu giả (Cấu trúc y hệt JSON từ Server)
      final List<Map<String, dynamic>> allMockRoutes = [
        {
          "id": 1,
          "name": "Núi Chứa Chan",
          "location": "Đồng Nai",
          "description": "Cận Sài Gòn, có thể cắm trại qua đêm, view hoàng hôn/bình minh cực đẹp.",
          "imageUrl": "https://images.unsplash.com/photo-1501785888041-af3ef285b470?q=80",
          "gallery": [
            "https://images.unsplash.com/photo-1501785888041-af3ef285b470?q=80",
            "https://images.unsplash.com/photo-1470770841072-f978cf4d019e?q=80"
          ],
          "totalDistanceKm": 10.5,
          "elevationGainM": 800,
          "durationDays": 2,
          "tags": ["mountain", "camping", "sunrise", "beginner"]
        },
        {
          "id": 2,
          "name": "Pù Luông",
          "location": "Thanh Hóa",
          "description": "Thiên đường ruộng bậc thang, không khí trong lành, văn hóa bản địa đặc sắc.",
          "imageUrl": "https://images.unsplash.com/photo-1470770841072-f978cf4d019e?q=80",
          "gallery": [],
          "totalDistanceKm": 25.0,
          "elevationGainM": 700,
          "durationDays": 3,
          "tags": ["rice-terraces", "cloud-hunting", "cultural", "homestay"]
        },
        {
          "id": 3,
          "name": "Tà Năng - Phan Dũng",
          "location": "Lâm Đồng - Bình Thuận",
          "description": "Cung đường trekking đẹp nhất Việt Nam, băng qua 3 tỉnh với đồi cỏ trải dài.",
          "imageUrl": "https://images.unsplash.com/photo-1533240332313-0dbdd3199061?q=80",
          "gallery": [],
          "totalDistanceKm": 55.0,
          "elevationGainM": 1100,
          "durationDays": 3,
          "tags": ["endurance", "grassland", "camping", "hard"]
        }
      ];

      // LOGIC LỌC GIẢ (Để search hoạt động được offline)
      if (_searchLocation.isNotEmpty) {
        final query = _searchLocation.toLowerCase();
        return allMockRoutes.where((route) {
          final name = (route['name'] as String).toLowerCase();
          final loc = (route['location'] as String).toLowerCase();
          return name.contains(query) || loc.contains(query);
        }).toList();
      }

      return allMockRoutes;
    }
  }

  // 2. Save Input History (Lưu API)
  Future<void> saveHistoryInput(String templateName) async {
    if (_searchLocation.isEmpty || _accommodation == null || _paxGroup == null || _difficultyLevel == null) {
      throw Exception("Vui lòng điền đầy đủ thông tin trước khi lưu.");
    }

    final Map<String, dynamic> apiBody = {
      'templateName': templateName,
      'location': _searchLocation,
      'restType': _accommodation ?? '',
      'groupSize': parsedGroupSize,
      'startDate': _formatDate(_startDate),
      'durationDays': durationDays,
      'difficulty': _difficultyLevel ?? '',
      'personalInterest': _selectedInterests,
      'note': _note,
    };

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/history-inputs/'),
        headers: _authHeaders,
        body: json.encode(apiBody),
      );

      if (response.statusCode != 201) {
        print("Lỗi lưu server: ${response.body}");
        // Có thể không throw exception nếu muốn "lưu giả" thành công
      }
    } catch (e) {
      print("Không lưu được lên server ($e), bỏ qua bước này để demo.");
    }
  }

  // 3. Create Plan (Tạo chuyến đi)
  Future<dynamic> createPlan({required int routeId}) async {
    final Map<String, dynamic> body = {
      'name': _tripName.isNotEmpty ? _tripName : "Chuyến đi $_searchLocation",
      'route': routeId,
      'location': _searchLocation,
      'restType': _accommodation ?? '',
      'groupSize': parsedGroupSize,
      'startDate': _formatDate(_startDate),
      'durationDays': durationDays,
      'difficulty': _difficultyLevel ?? '',
      'personalInterest': _selectedInterests,
    };

    try {
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
    } catch (e) {
      // Fallback giả lập thành công để test UI
      await Future.delayed(const Duration(seconds: 1));
      return {"id": 999, "message": "Plan created successfully (Offline mode)"};
    }
  }
}