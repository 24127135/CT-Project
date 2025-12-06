import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trip_provider.dart';
import '../services/supabase_db_service.dart';
// Import all steps to build the navigation stack
import 'tripinfopart1.dart';
import 'tripinfopart2.dart';
import 'tripinfopart3.dart';
import 'tripinfopart4.dart';
import 'tripinfopart5.dart';

class FastInputListView extends StatefulWidget {
  const FastInputListView({super.key});

  @override
  State<FastInputListView> createState() => _FastInputListViewState();
}

class _FastInputListViewState extends State<FastInputListView> {
  final SupabaseDbService _db = SupabaseDbService();
  late Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _refreshHistory();
  }

  void _refreshHistory() {
    setState(() {
      _historyFuture = _db.getHistoryInputs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Mẫu nhập nhanh',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _historyFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)));
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState();
                  }

                  final templates = snapshot.data!;
                  return RefreshIndicator(
                    onRefresh: () async => _refreshHistory(),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: templates.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildTemplateCard(context, templates[index]),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.post_add, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text("Bạn chưa có mẫu nào.", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          const SizedBox(height: 8),
          const Text(
            "Hãy tạo một chuyến đi và nhấn 'Lưu mẫu'\nở bước cuối cùng.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(BuildContext context, Map<String, dynamic> tpl) {
    final name = tpl['template_name'] ?? tpl['name'] ?? 'Mẫu mới';
    final location = tpl['location'] ?? tpl['payload']?['location'] ?? '';
    final duration = tpl['duration_days'] ?? tpl['payload']?['duration_days'];
    final restType = tpl['rest_type'] ?? tpl['payload']?['rest_type'] ?? '';
    final groupSize = tpl['group_size'] ?? tpl['payload']?['group_size'];

    String subtitleLeft = location;
    if (duration != null) subtitleLeft = '$subtitleLeft • ${duration.toString()} ngày';
    String subtitleRight = restType;
    if (groupSize != null) {
      final gs = (groupSize is int) ? groupSize : int.tryParse(groupSize.toString()) ?? 0;
      final label = gs >= 7 ? 'Nhóm đông (7+ người)' : (gs >= 3 ? 'Nhóm nhỏ (3-6 người)' : 'Đơn lẻ (1-2 người)');
      subtitleRight = '$subtitleRight • $label';
    }

    return GestureDetector(
      onTap: () {
        // Apply history input to provider
        context.read<TripProvider>().applyHistoryInput(tpl);

        // Push the trip info stack so user can continue/edit
        Navigator.push(context, _noAnimRoute(const TripInfoScreen()));
        Navigator.push(context, _noAnimRoute(const TripTimeScreen()));
        Navigator.push(context, _noAnimRoute(const TripLevelScreen()));
        Navigator.push(context, _noAnimRoute(const TripRequestScreen()));
        Navigator.push(context, _noAnimRoute(const TripConfirmScreen()));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
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
             Positioned.fill(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.2)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      name,
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
                            subtitleLeft,
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitleRight,
                      style: const TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                   ],
                 ),
               ),
             ),
            // Delete button (painted last so it's on top)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Xóa mẫu'),
                      content: const Text('Bạn có chắc muốn xóa mẫu này?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
                        TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );

                  if (confirmed != true) return;
                  try {
                    final db = SupabaseDbService();
                    final id = tpl['id'];
                    if (id is int) {
                      await db.deleteHistoryInput(id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa mẫu'), backgroundColor: Colors.green));
                      }
                      // Refresh the list
                      if (mounted) setState(() { _refreshHistory(); });
                    } else {
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không tìm thấy id mẫu'), backgroundColor: Colors.red));
                    }
                  } catch (e) {
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi xóa: $e'), backgroundColor: Colors.red));
                  }
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

  // Helper for instant navigation (No Animation)
  PageRouteBuilder _noAnimRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }
}