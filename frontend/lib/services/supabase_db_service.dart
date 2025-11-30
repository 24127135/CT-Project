import 'package:supabase_flutter/supabase_flutter.dart';
import 'danger_labels.dart'; // Ensure this file exists from the 'tri' branch

class SupabaseDbService {
  final _client = Supabase.instance.client;

  String? get _uid => _client.auth.currentUser?.id;

  // --- 1. ROUTES ---

  Future<List<Map<String, dynamic>>> getSuggestedRoutes({
    String? location,
    String? difficulty,
    String? accommodation,
    int? durationDays,
  }) async {
    try {
      var query = _client.from('routes').select();

      if (difficulty != null && difficulty.isNotEmpty) {
        query = query.eq('difficulty_level', difficulty);
      }

      final res = await query.order('id', ascending: true);
      List<Map<String, dynamic>> routes = List<Map<String, dynamic>>.from(res as List<dynamic>);

      final keyword = (location ?? '').toLowerCase().trim();
      final accomFilter = (accommodation ?? '').toLowerCase().trim();

      routes = routes.where((route) {
        if (keyword.isNotEmpty) {
          final name = (route['name'] ?? '').toString().toLowerCase();
          final desc = (route['description'] ?? '').toString().toLowerCase();
          final tagsList = route['tags'] as List<dynamic>? ?? [];
          final tagsString = tagsList.join(' ').toLowerCase();
          bool matchLoc = name.contains(keyword) || desc.contains(keyword) || tagsString.contains(keyword);
          if (!matchLoc) return false;
        }
        if (accomFilter.isNotEmpty && !accomFilter.contains('kết hợp')) {
          final tagsList = route['tags'] as List<dynamic>? ?? [];
          final tagsString = tagsList.join(' ').toLowerCase();
          if (!tagsString.contains(accomFilter)) return false;
        }
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

  // --- 2. PROFILES ---

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

  // [MERGED] From 'tri': Include 'routes' relation for Dashboard UI
  Future<List<dynamic>> getPlans() async {
    final uid = _uid;
    if (uid == null) return [];
    // Using the relationship to fetch route data immediately
    final res = await _client.from('plans').select('*, routes(*)').eq('user_id', uid).order('id', ascending: false);
    return res as List<dynamic>;
  }

  Future<void> deletePlan(int id) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not signed in');
    await _client.from('plans').delete().eq('id', id).eq('user_id', uid);
  }

  // [MERGED] From 'HEAD': Keep Strict Typed Parameters for compatibility with existing Trip Creation UI
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

  // [MERGED] From 'HEAD': Critical for AI PEC flow
  Future<Map<String, dynamic>> updatePlanRoute(int planId, int routeId, {Map<String, dynamic>? checklist}) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not signed in');

    print("🔄 Sending PATCH update to Supabase for Plan ID: $planId with Route ID: $routeId");

    final Map<String, dynamic> updates = {
      'route_id': routeId,
    };

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

  // [MERGED] From 'tri': Needed for Safety Warning Pop-up
  Future<String?> getLatestDangerSnapshot() async {
    final uid = _uid;
    if (uid == null) return null;

    final res = await _client.from('plans').select('id, dangers_snapshot').eq('user_id', uid).order('id', ascending: false).limit(1).maybeSingle();
    if (res == null) return null;

    final Map<String, dynamic> row = Map<String, dynamic>.from(res);
    final val = row['dangers_snapshot'];

    if (val is String && val.trim().isNotEmpty) return val.trim();

    if (val is Map) {
      final Map m = val;
      final active = <String>[];
      m.forEach((k, v) {
        if (v == true) {
            final key = k.toString();
            final label = dangerLabelForKey(key);
            active.add(label);
        }
      });
      if (active.isNotEmpty) return active.join(', ');
      return null;
    }

    if (val is List) {
      final items = val.where((e) => e != null).map((e) {
        final key = e.toString();
        return dangerLabelForKey(key);
      }).toList();
      if (items.isNotEmpty) return items.join(', ');
    }

    return null;
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