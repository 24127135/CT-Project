import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDbService {
  final _client = Supabase.instance.client;

  String? get _uid => _client.auth.currentUser?.id;

  // --- 1. ROUTES (CUNG ĐƯỜNG) ---

  /// Lấy danh sách cung đường gợi ý từ bảng 'routes'
  Future<List<Map<String, dynamic>>> getSuggestedRoutes({
    String? location,
    String? difficulty,
    String? accommodation,
    int? durationDays,
  }) async {
    try {
      // 1. Lấy dữ liệu thô từ DB
      var query = _client.from('routes').select();

      if (difficulty != null && difficulty.isNotEmpty) {
        query = query.eq('difficulty_level', difficulty);
      }

      final res = await query.order('id', ascending: true);
      List<Map<String, dynamic>> routes = List<Map<String, dynamic>>.from(res as List<dynamic>);

      // 2. Lọc Logic phía Client
      final keyword = (location ?? '').toLowerCase().trim();
      final accomFilter = (accommodation ?? '').toLowerCase().trim();

      routes = routes.where((route) {
        // A. Lọc Location
        if (keyword.isNotEmpty) {
          final name = (route['name'] ?? '').toString().toLowerCase();
          final desc = (route['description'] ?? '').toString().toLowerCase();
          final tagsList = route['tags'] as List<dynamic>? ?? [];
          final tagsString = tagsList.join(' ').toLowerCase();

          bool matchLoc = name.contains(keyword) || desc.contains(keyword) || tagsString.contains(keyword);
          if (!matchLoc) return false;
        }

        // B. Lọc Accommodation
        if (accomFilter.isNotEmpty && !accomFilter.contains('kết hợp')) {
          final tagsList = route['tags'] as List<dynamic>? ?? [];
          final tagsString = tagsList.join(' ').toLowerCase();
          if (!tagsString.contains(accomFilter)) return false;
        }

        // C. Lọc Duration
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

  /// Delete a plan by id
  Future<void> deletePlan(int id) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not signed in');
    await _client.from('plans').delete().eq('id', id).eq('user_id', uid);
  }

  Future<Map<String, dynamic>> createPlan({
    required String name,
    int? routeId,
    required String location,
    required String restType,
    required int groupSize,
    required String startDate,
    required int durationDays,
    required String difficulty,
    required List<String> personalInterests,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not signed in');

    final payload = {
      'user_id': uid,
      'name': name,
      'route_id': routeId,
      'location': location,
      'rest_type': restType,
      'group_size': groupSize,
      'start_date': startDate,
      'duration_days': durationDays,
      'difficulty': difficulty,
      'personal_interests': personalInterests,
    };

    final res = await _client.from('plans').insert(payload).select().single();
    return Map<String, dynamic>.from(res);
  }

  // ---------------------------------------------------------------------------
  // [UPDATED] Update Plan Route AND Checklist
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> updatePlanRoute(int planId, int routeId, {Map<String, dynamic>? checklist}) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not signed in');

    print("🔄 Sending PATCH update to Supabase for Plan ID: $planId with Route ID: $routeId");

    // Prepare update payload
    final Map<String, dynamic> updates = {
      'route_id': routeId,
    };

    // If checklist is provided (from Gemini in Frontend), save it directly to DB
    if (checklist != null) {
      updates['personalized_equipment_list'] = checklist;
    }

    final res = await _client
        .from('plans')
        .update(updates)
        .eq('id', planId)
        .select()
        .single();
        
    return Map<String, dynamic>.from(res);
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

    data['location'] = payload['location'] ?? payload['payload']?['location'];
    data['rest_type'] = payload['rest_type'] ?? payload['payload']?['rest_type'] ?? payload['accommodation'];
    data['group_size'] = payload['group_size'] ?? payload['payload']?['group_size'] ?? payload['pax_group'];
    data['start_date'] = payload['start_date'] ?? payload['payload']?['start_date'];
    data['duration_days'] = payload['duration_days'] ?? payload['payload']?['duration_days'];
    data['difficulty'] = payload['difficulty'] ?? payload['payload']?['difficulty'] ?? payload['difficulty_level'];

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