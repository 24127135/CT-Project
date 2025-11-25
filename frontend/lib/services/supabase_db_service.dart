import 'package:supabase_flutter/supabase_flutter.dart';

/// Lightweight Supabase DB service for basic CRUD against `profiles`, `plans`, and related tables.
/// Use this from UI code or providers to read/write data using the client's authenticated session.
class SupabaseDbService {
  final _client = Supabase.instance.client;

  /// Returns the current user's id or null if not signed in.
  String? get _uid => _client.auth.currentUser?.id;

  /// Fetch the current user's profile (or null if not found).
  Future<Map<String, dynamic>?> getProfile() async {
    final uid = _uid;
    if (uid == null) return null;

    final resp = await _client.from('profiles').select().eq('user_id', uid).maybeSingle();
    if (resp == null) return null;
    return Map<String, dynamic>.from(resp);
  }

  /// Upsert the profile for the current user. `data` can include `full_name`, `email`, `metadata`, etc.
  Future<void> upsertProfile(Map<String, dynamic> data) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not signed in');

    // Ensure we set user_id so RLS checks allow the insert/update
    final payload = Map<String, dynamic>.from(data);
    payload['user_id'] = uid;

    final res = await _client.from('profiles').upsert(payload).select().maybeSingle();
    if (res == null) throw Exception('Upsert profile returned null');
  }

  /// Fetch plans for the current user.
  Future<List<dynamic>> getPlans() async {
    final uid = _uid;
    if (uid == null) return [];

    final res = await _client.from('plans').select().eq('user_id', uid);
    return res as List<dynamic>;
  }

  /// Create a plan for the current user. `body` should contain route_id, name, start_date, end_date, data, etc.
  Future<Map<String, dynamic>> createPlan(Map<String, dynamic> body) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not signed in');

    final payload = Map<String, dynamic>.from(body);
    payload['user_id'] = uid;

    final res = await _client.from('plans').insert(payload).select().single();
    return Map<String, dynamic>.from(res);
  }

  /// Save a history input (template)
  Future<void> saveHistoryInput(String name, Map<String, dynamic> payload) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not signed in');

    await _client.from('history_inputs').insert({
      'user_id': uid,
      'name': name,
      'payload': payload,
    });
  }
}
