import 'package:flutter/material.dart';
import '../models/trip_template.dart';
import '../services/supabase_db_service.dart';

class TripProvider with ChangeNotifier {

  // Khởi tạo Service Supabase
  final SupabaseDbService _supabaseDb = SupabaseDbService();

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

  // --- Logic Apply Template & History (Giữ nguyên) ---
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

  void applyHistoryInput(Map<String, dynamic> data) {
    _searchLocation = data['location'] ?? data['payload']?['location'] ?? '';
    _accommodation = data['rest_type'] ?? data['payload']?['rest_type'];

    final gs = data['group_size'] ?? data['payload']?['group_size'];
    if (gs is int) {
      if (gs >= 7) _paxGroup = 'Nhóm đông (7+ người)';
      else if (gs >= 3) _paxGroup = 'Nhóm nhỏ (3-6 người)';
      else _paxGroup = 'Đơn lẻ (1-2 người)';
    } else if (gs is String) {
      _paxGroup = gs;
    }

    final sd = data['start_date'] ?? data['payload']?['start_date'];
    final dd = data['duration_days'] ?? data['payload']?['duration_days'];
    if (sd != null) {
      try {
        final parsed = DateTime.parse(sd.toString());
        _startDate = DateTime(parsed.year, parsed.month, parsed.day);
        final d = (dd is int) ? dd : int.tryParse(dd?.toString() ?? '') ?? 1;
        _endDate = _startDate!.add(Duration(days: d - 1));
      } catch (_) {
        _startDate = null; _endDate = null;
      }
    }
    _difficultyLevel = data['difficulty'] ?? data['payload']?['difficulty'];
    final interests = data['personal_interests'] ?? data['payload']?['personal_interests'];
    if (interests is List) {
      _selectedInterests = List<String>.from(interests.map((e) => e.toString()));
    }
    _tripName = data['template_name'] ?? data['name'] ?? _tripName;
    notifyListeners();
  }

  Future<void> saveHistoryInput(String name) async {
    if (_searchLocation.isEmpty || _accommodation == null || _paxGroup == null || _difficultyLevel == null) {
      throw Exception("Vui lòng điền đầy đủ thông tin trước khi lưu.");
    }
    final payload = {
      'location': _searchLocation,
      'rest_type': _accommodation,
      'group_size': parsedGroupSize,
      'start_date': _startDate != null ? DateTime(_startDate!.year, _startDate!.month, _startDate!.day).toIso8601String().split('T').first : null,
      'duration_days': durationDays,
      'difficulty': _difficultyLevel,
      'personal_interests': _selectedInterests,
    };
    await _supabaseDb.saveHistoryInput(name, payload);
  }

  // --- FEATURE QUAN TRỌNG NHẤT: FETCH ROUTES ---
  // Đã chuyển sang gọi Supabase trực tiếp
  Future<List<dynamic>> fetchSuggestedRoutes() async {
    try {
      debugPrint("🔌 Đang gọi Supabase lấy danh sách cung đường...");

      // Gọi hàm Service vừa viết
      final data = await _supabaseDb.getSuggestedRoutes(
        location: _searchLocation,
        difficulty: _difficultyLevel,
        accommodation: _accommodation,
        durationDays: durationDays,
      );

      debugPrint("✅ Supabase trả về ${data.length} kết quả.");

      // Client-side filtering phụ trợ (nếu cần)
      // Ví dụ: Lọc thêm theo tags nếu Supabase search chưa đủ sâu
      // Nhưng ở đây ta cứ trả về data thô, UI sẽ lo phần hiển thị
      return data;

    } catch (e) {
      debugPrint("❌ Lỗi Fetch Route: $e");
      // Trả về rỗng để UI hiện thông báo Empty State thay vì crash
      return [];
    }
  }

  // Hàm reset
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