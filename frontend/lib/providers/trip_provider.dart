import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../models/trip_template.dart';
import '../services/template_service.dart';

class TripProvider with ChangeNotifier {
  // --- CẤU HÌNH API ---
  // FIXED: Gán cứng IP để tránh lỗi "No host specified". 
  // Dùng '10.0.2.2' cho Android Emulator. Nếu chạy máy thật hãy thay bằng IP LAN (VD: 192.168.1.x)
  static const String _serverIp = '10.0.2.2'; 
  
  static const String _baseUrl = 'http://$_serverIp:8000/api';
  
  final ApiService _api = ApiService();
  final TemplateService _templateService = TemplateService();

  TripProvider([String? unused]);

  // --- State Variables ---
  String _searchLocation = '';
  String? _accommodation;
  String? _paxGroup;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _difficultyLevel;
  String _note = '';
  List<String> _selectedInterests = [];
  String _tripName = ''; 

  // --- Getters ---
  String get searchLocation => _searchLocation;
  String? get accommodation => _accommodation;
  String? get paxGroup => _paxGroup;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String? get difficultyLevel => _difficultyLevel;
  String get note => _note;
  List<String> get selectedInterests => _selectedInterests;
  String get tripName => _tripName;

  int get durationDays {
    if (_startDate == null || _endDate == null) return 1;
    return _endDate!.difference(_startDate!).inDays + 1;
  }
  
  // Helper chuyển đổi nhóm người
  int get parsedGroupSize {
    if (_paxGroup == 'Đơn lẻ (1-2 người)') return 2;
    if (_paxGroup == 'Nhóm nhỏ (3-6 người)') return 5;
    if (_paxGroup == 'Nhóm đông (7+ người)') return 8;
    return 1;
  }

  // --- Setters ---
  void setSearchLocation(String value) { _searchLocation = value; notifyListeners(); }
  void setAccommodation(String value) { _accommodation = value; notifyListeners(); }
  void setPaxGroup(String value) { _paxGroup = value; notifyListeners(); }
  void setDifficultyLevel(String value) { _difficultyLevel = value; notifyListeners(); }
  void setNote(String value) { _note = value; notifyListeners(); }
  void setTripName(String value) { _tripName = value; notifyListeners(); }

  void setTripDates(DateTime start, DateTime end) {
    _startDate = DateTime(start.year, start.month, start.day);
    _endDate = DateTime(end.year, end.month, end.day);
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

  // --- FEATURE 1: APPLY TEMPLATE ---
  void applyTemplate(TripTemplate template) {
    _searchLocation = template.location;
    _accommodation = template.accommodation;
    _paxGroup = template.paxGroup;
    _difficultyLevel = template.difficulty;
    _note = template.note;
    _selectedInterests = List.from(template.interests);
    _tripName = template.name;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _startDate = today.add(const Duration(days: 1));
    int d = template.durationDays < 1 ? 1 : template.durationDays;
    _endDate = _startDate!.add(Duration(days: d - 1));
    notifyListeners();
  }

  // --- FEATURE 2: SAVE TEMPLATE ---
  Future<void> saveHistoryInput(String name) async {
    if (_searchLocation.isEmpty || _accommodation == null || _paxGroup == null || _difficultyLevel == null) {
      throw Exception("Vui lòng điền đầy đủ thông tin trước khi lưu.");
    }

    final templateData = {
      "name": name,
      "location": _searchLocation,
      "accommodation": _accommodation,
      "pax_group": _paxGroup,
      "difficulty": _difficultyLevel,
      "duration_days": durationDays,
      "note": _note,
      "interests": _selectedInterests,
    };

    bool success = await _templateService.saveTemplate(templateData);
    if (!success) {
      throw Exception("Lưu thất bại. Vui lòng kiểm tra kết nối.");
    }
  }

  // --- FEATURE 3: FETCH SUGGESTED ROUTES (LOGIC ĐÃ SỬA) ---
  Future<List<dynamic>> fetchSuggestedRoutes() async {
    // 1. Chuẩn bị tham số
    final Map<String, dynamic> queryParams = {};
    if (_searchLocation.isNotEmpty) queryParams['location'] = _searchLocation;
    if (_difficultyLevel != null) queryParams['difficulty'] = _difficultyLevel;

    // 2. Gọi API SERVER (Ưu tiên)
    try {
      final uri = Uri.parse('$_baseUrl/routes/suggested/')
          .replace(queryParameters: queryParams);

      print("🔌 Đang gọi API: $uri");
      final response = await http.get(uri).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print("✅ API trả về ${data.length} kết quả.");
        return data;
      } else {
        // Nếu Server lỗi (500, 404...), in lỗi và để code chạy tiếp xuống phần Mock Data
        print("⚠️ Server trả về lỗi: ${response.statusCode}");
      }
    } catch (e) {
      // Nếu mất mạng hoặc timeout, in lỗi và để code chạy tiếp xuống phần Mock Data
      print("⚠️ Lỗi kết nối API ($e). Đang chuyển sang Offline Mode...");
    }

    // 3. FALLBACK: MOCK DATA (Chỉ chạy khi có Exception hoặc Server lỗi != 200)
    print("ℹ️ Đang sử dụng dữ liệu giả lập (Offline Mode)");
    await Future.delayed(const Duration(milliseconds: 500));

    final List<Map<String, dynamic>> backupRoutes = [
      {
        "id": 1,
        "name": "Chư Đăng Ya",
        "location": "Gia Lai",
        "description": "Miệng núi lửa cổ, thiên đường hoa dã quỳ.",
        "imageUrl": "https://images.unsplash.com/photo-1501785888041-af3ef285b470?q=80",
        "gallery": ["https://images.unsplash.com/photo-1501785888041-af3ef285b470?q=80"],
        "totalDistanceKm": 5.0,
        "elevationGainM": 400,
        "durationDays": 1,
        "tags": ["volcano", "flowers", "gia-lai"]
      },
      {
        "id": 2,
        "name": "Núi Chứa Chan",
        "location": "Đồng Nai",
        "description": "Cung đường trekking quốc dân gần Sài Gòn.",
        "imageUrl": "https://images.unsplash.com/photo-1470770841072-f978cf4d019e?q=80",
        "gallery": [],
        "totalDistanceKm": 10.5,
        "elevationGainM": 800,
        "durationDays": 2,
        "tags": ["mountain", "camping", "dong-nai"]
      },
      {
        "id": 3,
        "name": "Tà Năng - Phan Dũng",
        "location": "Lâm Đồng",
        "description": "Cung đường trekking đẹp nhất Việt Nam.",
        "imageUrl": "https://images.unsplash.com/photo-1533240332313-0dbdd3199061?q=80",
        "gallery": [],
        "totalDistanceKm": 55.0,
        "elevationGainM": 1100,
        "durationDays": 3,
        "tags": ["grassland", "lam-dong"]
      }
    ];

    // LOGIC LỌC OFFLINE
    if (_searchLocation.isNotEmpty) {
      final query = _removeDiacritics(_searchLocation).toLowerCase();

      final filtered = backupRoutes.where((r) {
        final loc = _removeDiacritics(r['location'].toString()).toLowerCase();
        final name = _removeDiacritics(r['name'].toString()).toLowerCase();
        return loc.contains(query) || name.contains(query);
      }).toList();

      // FIX 2: Nếu lọc Offline ra rỗng, trả về rỗng luôn.
      // Điều này giúp UI hiển thị thông báo "Không tìm thấy chuyến đi nào ở [Địa điểm]"
      // Thay vì tự động hiện lại toàn bộ danh sách gây khó hiểu.
      return filtered;
    }

    return backupRoutes;
  }

  String _removeDiacritics(String str) {
    const withDia = 'áàảãạăắằẳẵặâấầẩẫậđéèẻẽẹêếềểễệíìỉĩịóòỏõọôốồổỗộơớờởỡợúùủũụưứừửữựýỳỷỹỵ';
    const withoutDia = 'aaaaaaaaaaaaaaaaadeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyy';
    var result = str;
    for (int i = 0; i < withDia.length; i++) {
      result = result.replaceAll(withDia[i], withoutDia[i]);
    }
    return result;
  }

  // --- FEATURE 4: RESET ---
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
}