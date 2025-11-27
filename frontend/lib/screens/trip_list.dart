import 'package:flutter/material.dart';
import '../services/supabase_db_service.dart';
import 'trip_dashboard.dart';

/// Trip list view.
///
/// Displays plans from the `plans` table for the current authenticated user.
class TripListView extends StatefulWidget {
  const TripListView({super.key});

  @override
  State<TripListView> createState() => _TripListViewState();
}

class _TripListViewState extends State<TripListView> {
  final SupabaseDbService _db = SupabaseDbService();
  late Future<List<Map<String, dynamic>>> _plansFuture;

  @override
  void initState() {
    super.initState();
    _plansFuture = _loadPlans();
  }

  Future<List<Map<String, dynamic>>> _loadPlans() async {
    final res = await _db.getPlans();
    // Expecting list of map-like objects. Normalize to List<Map<String, dynamic>>
    return List<Map<String, dynamic>>.from(res.map((e) => Map<String, dynamic>.from(e)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Danh sách chuyến đi của bạn',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // List card
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _plansFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)));
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Lỗi tải chuyến đi: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sentiment_dissatisfied, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text('Bạn chưa có chuyến đi nào.', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                        ],
                      ),
                    );
                  }

                  final plans = snapshot.data!;
                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        _plansFuture = _loadPlans();
                      });
                      await _plansFuture;
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                      itemCount: plans.length,
                      itemBuilder: (context, index) {
                        final plan = plans[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _PlanCard(
                            plan: plan,
                            onDeleteRequested: () async {
                              final scaffold = ScaffoldMessenger.of(context);
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Xóa chuyến đi'),
                                  content: const Text('Bạn có chắc muốn xóa chuyến đi này?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
                                  ],
                                ),
                              );
                              if (!mounted) return;
                              if (confirmed != true) return;
                              final idVal = plan['id'];
                              if (idVal == null) {
                                if (!mounted) return;
                                scaffold.showSnackBar(const SnackBar(content: Text('Không tìm thấy id chuyến đi'), backgroundColor: Colors.red));
                                return;
                              }
                              try {
                                final id = (idVal is int) ? idVal : int.parse(idVal.toString());
                                await _db.deletePlan(id);
                                if (!mounted) return;
                                scaffold.showSnackBar(const SnackBar(content: Text('Đã xóa chuyến đi'), backgroundColor: Colors.green));
                                setState(() {
                                  _plansFuture = _loadPlans();
                                });
                              } catch (e) {
                                if (!mounted) return;
                                scaffold.showSnackBar(SnackBar(content: Text('Lỗi xóa: $e'), backgroundColor: Colors.red));
                              }
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final Future<void> Function() onDeleteRequested;

  const _PlanCard({required this.plan, required this.onDeleteRequested});

  @override
  Widget build(BuildContext context) {
    final title = plan['name'] ?? plan['title'] ?? 'Chuyến đi không tên';
    final location = plan['location'] ?? '';
    final duration = plan['duration_days'] ?? plan['duration'];

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const TripDashboard()));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Gradient background matching the fast input card style.
            Container(
              height: 180,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF425E3C), Color(0xFF2E7D32)],
                ),
              ),
            ),

            // Content overlay
            Positioned.fill(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.2)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location + (duration != null ? ' • ${duration.toString()} ngày' : ''),
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text((plan['rest_type'] ?? '') as String, style: const TextStyle(color: Colors.white60, fontSize: 13)),
                  ],
                ),
              ),
            ),

            // Action: delete
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  // Call the async delete callback without awaiting here to
                  // satisfy the GestureDetector's sync callback signature.
                  onDeleteRequested();
                },
                child: Container(
                  decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.delete_outline, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}