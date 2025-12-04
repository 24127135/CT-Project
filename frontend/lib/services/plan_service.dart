import 'dart:convert';

import 'supabase_db_service.dart';
import '../models/plan.dart';

class PlanService {
  final SupabaseDbService db;

  PlanService({SupabaseDbService? db}) : db = db ?? SupabaseDbService();

  /// Returns the latest plan as a typed [Plan] or null.7
  Future<Plan?> getLatestPlan() async {
    final plans = await db.getPlans();
    if (plans.isEmpty) return null;
    final first = plans.first;
    return parsePlan(first);
  }

  /// Returns all plans as a list of typed [Plan].
  Future<List<Plan>> getPlans() async {
    final raw = await db.getPlans();
    final out = <Plan>[];
    for (final item in raw) {
      final parsed = parsePlan(item);
      if (parsed != null) out.add(parsed);
    }
    return out;
  }

  /// Parse raw plan data into a typed [Plan].
  Plan? parsePlan(dynamic raw) {
    if (raw == null) return null;

    // If raw is a JSON string, attempt to decode it to a Map
    if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        return Plan.fromDynamic(decoded);
      } catch (_) {
        return null;
      }
    }

    return Plan.fromDynamic(raw);
  }
}
