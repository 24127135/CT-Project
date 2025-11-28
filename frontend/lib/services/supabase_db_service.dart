import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDbService {
  final _client = Supabase.instance.client;

  String? get _uid => _client.auth.currentUser?.id;

  // --- 1. ROUTES (CUNG ĐƯỜNG) ---

  /// Lấy danh sách cung đường gợi ý từ bảng 'routes'
  Future<List<Map<String, dynamic>>> getSuggestedRoutes({
    String? location,
    String? difficulty,
    String? accommodation, // MỚI: Cắm trại / Homestay / Kết hợp
    int? durationDays,     // MỚI: Số ngày đi
  }) async {
    try {
      // 1. Lấy dữ liệu thô từ DB
      var query = _client.from('routes').select();

      // Lọc độ khó tại DB
      if (difficulty != null && difficulty.isNotEmpty) {
        query = query.eq('difficulty_level', difficulty);
      }

      final res = await query.order('id', ascending: true);
      List<Map<String, dynamic>> routes = List<Map<String, dynamic>>.from(res as List<dynamic>);

      // 2. Lọc Logic phía Client (Dart)

      // Chuẩn hóa input tìm kiếm
      final keyword = (location ?? '').toLowerCase().trim();
      final accomFilter = (accommodation ?? '').toLowerCase().trim(); // "cắm trại", "homestay"

      routes = routes.where((route) {
        // --- A. Lọc Location ---
        if (keyword.isNotEmpty) {
          final name = (route['name'] ?? '').toString().toLowerCase();
          final desc = (route['description'] ?? '').toString().toLowerCase();
          final tagsList = route['tags'] as List<dynamic>? ?? [];
          final tagsString = tagsList.join(' ').toLowerCase();

          bool matchLoc = name.contains(keyword) || desc.contains(keyword) || tagsString.contains(keyword);
          if (!matchLoc) return false;
        }

        // --- B. Lọc Accommodation (Loại hình ngủ nghỉ) ---
        // Nếu user chọn "Kết hợp" hoặc không chọn -> Bỏ qua lọc (lấy hết)
        // Nếu chọn "Cắm trại" hoặc "Homestay" -> Bắt buộc route phải có tag đó
        if (accomFilter.isNotEmpty && !accomFilter.contains('kết hợp')) {
          final tagsList = route['tags'] as List<dynamic>? ?? [];
          final tagsString = tagsList.join(' ').toLowerCase();

          // Kiểm tra xem tag của route có chứa loại hình user chọn không
          if (!tagsString.contains(accomFilter)) return false;
        }

        // --- C. Lọc Duration (Số ngày) ---
        // Logic: Lấy các cung đường có thời gian chênh lệch <= 1 ngày so với user chọn
        // VD: User đi 3 ngày -> Gợi ý cung 2, 3, 4 ngày.
        if (durationDays != null) {
          final routeDays = (route['estimated_duration_days'] ?? 0) as int;
          if ((routeDays - durationDays).abs() > 1) return false;
        }

        return true;
      }).toList();

      return routes;

    } catch (e) {
      print("❌ Lỗi Logic: $e");
      return [];
    }
  }
  /// Delete a plan by id (only if it belongs to current user)
  Future<void> deletePlan(int id) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not signed in');

    // Xóa trong bảng 'plans' với id tương ứng và phải thuộc về user hiện tại
    await _client.from('plans').delete().eq('id', id).eq('user_id', uid);
  }
  // --- 2. USER PROFILES ---

  Future<Map<String, dynamic>?> getProfile() async {
    final uid = _uid;
    if (uid == null) return null;
    final resp = await _client.from('profiles').select().eq('user_id', uid).maybeSingle();
    if (resp == null) return null;
    return Map<String, dynamic>.from(resp);
  }

  Future<void> upsertProfile(Map<String, dynamic> data) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not signed in');
    final payload = Map<String, dynamic>.from(data);
    payload['user_id'] = uid;
    await _client.from('profiles').upsert(payload);
  }

  // --- 3. PLANS ---

  Future<List<dynamic>> getPlans() async {
    final uid = _uid;
    if (uid == null) return [];
    return await _client.from('plans').select().eq('user_id', uid);
  }

  Future<Map<String, dynamic>> createPlan(Map<String, dynamic> body) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not signed in');
    final payload = Map<String, dynamic>.from(body);
    payload['user_id'] = uid;
    return await _client.from('plans').insert(payload).select().single();
  }

  // --- 4. HISTORY INPUTS ---

  Future<List<Map<String, dynamic>>> getHistoryInputs() async {
    final uid = _uid;
    if (uid == null) return [];
    final res = await _client.from('history_inputs').select().eq('user_id', uid).order('id', ascending: false);
    return List<Map<String, dynamic>>.from(res as List<dynamic>);
  }

  Future<void> deleteHistoryInput(int id) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not signed in');
    await _client.from('history_inputs').delete().eq('id', id).eq('user_id', uid);
  }

  Future<Map<String, dynamic>> saveHistoryInput(String name, Map<String, dynamic> payload) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not signed in');

    final Map<String, dynamic> data = {};
    data['user_id'] = uid;
    data['template_name'] = name;
    // Map các trường payload linh hoạt
    data['location'] = payload['location'] ?? payload['payload']?['location'];
    data['rest_type'] = payload['rest_type'] ?? payload['payload']?['rest_type'] ?? payload['accommodation'];
    data['group_size'] = payload['group_size'] ?? payload['payload']?['group_size'] ?? payload['pax_group'];
    data['start_date'] = payload['start_date'] ?? payload['payload']?['start_date'];
    data['duration_days'] = payload['duration_days'] ?? payload['payload']?['duration_days'];
    data['difficulty'] = payload['difficulty'] ?? payload['payload']?['difficulty'] ?? payload['difficulty_level'];

    // Xử lý mảng interests
    var interests = payload['personal_interest'] ?? payload['personal_interests'] ?? payload['interests'];
    if (interests is List) {
      data['personal_interests'] = interests;
    } else {
      data['personal_interests'] = [];
    }

    final insertPayload = <String, dynamic>{};
    data.forEach((k, v) { if (v != null) insertPayload[k] = v; });

    final res = await _client.from('history_inputs').insert(insertPayload).select().single();
    return Map<String, dynamic>.from(res);
  }
}