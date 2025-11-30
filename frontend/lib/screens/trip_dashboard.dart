// Trip dashboard: single compact implementation
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/supabase_db_service.dart';
import '../services/plan_service.dart';
 
import '../models/plan.dart';
import '../services/danger_labels.dart';

const kBgColor = Color(0xFFF8F6F2);
const kPrimaryGreen = Color(0xFF38C148);

class TripDashboard extends StatefulWidget {
  const TripDashboard({super.key});

  @override
  State<TripDashboard> createState() => _TripDashboardState();
}

class _TripDashboardState extends State<TripDashboard> {
  final SupabaseDbService _db = SupabaseDbService();
  late final PlanService _planService = PlanService(db: _db);
  Plan? _latestPlan;
  int _activeIndex = 0;
  final PageController _pageController = PageController();
  final List<String> _notes = [];

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _initSafetyCheck());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: Column(
          children: [
            _TripHeader(onBackPressed: () => Navigator.of(context).pop(), onViewDanger: _showDangerViewer),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: _TripTabs(activeIndex: _activeIndex, onTabChanged: _onTab),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _activeIndex = i),
                children: [
                  _RouteTab(plan: _latestPlan),
                  _ItemsTab(plan: _latestPlan),
                  _NotesTab(notes: _notes, onDeleteNote: _deleteNote, onEditNote: _editNote),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _activeIndex == 2
          ? FloatingActionButton(
              backgroundColor: kPrimaryGreen,
              onPressed: _navigateAndAddNote,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  void _onTab(int i) {
    setState(() => _activeIndex = i);
    _pageController.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Future<void> _initSafetyCheck() async {
    final ctx = context;
    final navigator = Navigator.of(ctx);

    // Show an immediate, non-dismissible checking dialog so the user
    // sees a prompt right after pressing Trip Dashboard.
    showDialog<void>(
      context: ctx,
      barrierDismissible: false,
      builder: (c) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisSize: MainAxisSize.min, children: const [CircularProgressIndicator(), SizedBox(width: 16), Text('Đang kiểm tra cảnh báo...')]),
        ),
      ),
    );

    try {
      final latest = await _planService.getLatestPlan();
      if (!mounted) {
        if (navigator.canPop()) navigator.pop();
        return;
      }
      setState(() => _latestPlan = latest);

      // check danger snapshot and show modal if necessary
      try {
        final snapshot = await _db.getLatestDangerSnapshot();
        if (snapshot != null) {
          final pid = _latestPlan?.id;
          if (pid != null) {
            final ack = await _isAcknowledgedForPlan(pid);
            // dismiss the loading dialog first
            if (navigator.canPop()) navigator.pop();
            if (!ack) {
              final message = snapshot.toString();
              if (!mounted) return;
              await _showDangerWarning(navigator, message);
            }
            return;
          }
        }
        // no snapshot or not applicable: dismiss loading
        if (navigator.canPop()) navigator.pop();
      } catch (_) {
        if (navigator.canPop()) navigator.pop();
      }
    } catch (err) {
      // ignore errors but ensure any loading dialog is dismissed
      try {
        if (navigator.canPop()) navigator.pop();
      } catch (_) {}
    }
  }

  Future<void> _acknowledgePlan(int planId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ack_plan_$planId', true);
  }

  Future<bool> _isAcknowledgedForPlan(int planId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('ack_plan_$planId') ?? false;
  }

  // Per-danger acknowledgement (per plan)
  String _dangerStorageKey(int planId, String dangerKey) {
    final safe = dangerKey.replaceAll(RegExp(r"[^a-zA-Z0-9_]"), '_');
    return 'ack_plan_${planId}_danger_$safe';
  }

  Future<void> _setDangerAcknowledged(int planId, String dangerKey, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final k = _dangerStorageKey(planId, dangerKey);
    if (value) {
      await prefs.setBool(k, true);
    } else {
      await prefs.remove(k);
    }
  }

  Future<bool> _isDangerAcknowledged(int planId, String dangerKey) async {
    final prefs = await SharedPreferences.getInstance();
    final k = _dangerStorageKey(planId, dangerKey);
    return prefs.getBool(k) ?? false;
  }

  Future<void> _showDangerWarning(NavigatorState navigator, String message) async {
    if (!mounted) { return; }
    await showDialog<void>(
      context: navigator.context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
          child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 48),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 18, offset: Offset(0, 8))],
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('CẢNH BÁO NGUY HIỂM', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.6)),
                  const SizedBox(height: 10),
                     Text(message, textAlign: TextAlign.center, style: TextStyle(fontStyle: FontStyle.italic, height: 1.45, color: Color.fromRGBO(0,0,0,0.85))),
                ]),
              ),
            ),
            Positioned(
              bottom: -22,
              child: Material(
                color: Colors.transparent,
                elevation: 8,
                borderRadius: BorderRadius.circular(28),
                child: InkWell(
                  onTap: () async {
                    final pid = _latestPlan?.id;
                    if (pid != null) { await _acknowledgePlan(pid); }
                    if (!mounted) { return; }
                    navigator.pop();
                  },
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                    decoration: BoxDecoration(color: kPrimaryGreen, borderRadius: BorderRadius.circular(28)),
                    child: const Text('Đã hiểu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            )
          ]),
        );
      },
    );
  }

  String _formatDangerValue(dynamic val) {
    if (val == null) return 'Không có cảnh báo.';
    if (val is String) {
      final s = val.trim();
      return s.isEmpty ? 'Không có cảnh báo.' : s;
    }
    if (val is Map) {
      final parts = <String>[];
      val.forEach((k, v) {
        final label = dangerLabelForKey(k.toString());
          if (v == true) {
            parts.add(label);
          } else if (v != null) {
            parts.add('$label: ${v.toString()}');
          }
      });
      return parts.isNotEmpty ? parts.join('\n') : 'Không có cảnh báo.';
    }
    if (val is List) {
      final parts = val.where((e) => e != null).map((e) => dangerLabelForKey(e.toString())).toList();
      return parts.isNotEmpty ? parts.join(', ') : 'Không có cảnh báo.';
    }
    return val.toString();
  }

  Future<void> _showDangerViewer() async {
    final ctx = context;
    try {
      final snapshot = await _db.getLatestDangerSnapshot();
      final message = _formatDangerValue(snapshot);
      final pid = _latestPlan?.id;
      // Build danger entries list (key + value) so we can show multiple dangers
      final List<MapEntry<String, dynamic>> entries = [];
      if (snapshot is Map) {
        final Map snapMap = snapshot as Map;
        for (final e in snapMap.entries) {
          entries.add(MapEntry(e.key.toString(), e.value));
        }
      } else if (snapshot is List) {
        final List snapList = snapshot as List;
        for (var i = 0; i < snapList.length; i++) {
          entries.add(MapEntry(i.toString(), snapList[i]));
        }
      } else if (snapshot != null) {
        // snapshot might be a plain string or other scalar
        entries.add(MapEntry('message', snapshot));
      }

      // Preload ack status for each danger (if we have a plan id)
      final Map<String, bool> ackMap = {};
      if (pid != null) {
        for (final e in entries) {
          ackMap[e.key] = await _isDangerAcknowledged(pid, e.key);
        }
      }

      if (!mounted) { return; }
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted) { return; }
        showDialog<void>(
          context: ctx,
          builder: (context) {
            const bg = Colors.white;
            final accent = kPrimaryGreen;
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 8))],
                    ),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Center(child: Text('Chi tiết cảnh báo', textAlign: TextAlign.center, style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w900, fontSize: 20))),
                      const SizedBox(height: 8),
                      // Danger list
                      if (entries.isEmpty) ...[
                        Align(alignment: Alignment.centerLeft, child: Text(message, style: const TextStyle(fontStyle: FontStyle.italic, height: 1.35, color: Colors.black87))),
                      ] else ...[
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 320),
                          child: StatefulBuilder(builder: (context, setState) {
                            return ListView.separated(
                              shrinkWrap: true,
                              itemCount: entries.length,
                              separatorBuilder: (context, index) => const Divider(height: 1),
                              itemBuilder: (context, idx) {
                                final e = entries[idx];
                                final label = dangerLabelForKey(e.key);
                                final val = e.value;
                                final reviewed = ackMap[e.key] ?? false;
                                final color = reviewed ? Colors.amber : Colors.redAccent;
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  leading: CircleAvatar(radius: 10, backgroundColor: color),
                                  title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
                                  subtitle: val != null ? Text(val.toString()) : null,
                                  trailing: pid != null
                                      ? TextButton(
                                          onPressed: () async {
                                            final newVal = !(ackMap[e.key] ?? false);
                                            await _setDangerAcknowledged(pid, e.key, newVal);
                                            setState(() {
                                              ackMap[e.key] = newVal;
                                            });
                                          },
                                          child: Text(ackMap[e.key] == true ? 'Đã xem' : 'Chưa xem', style: TextStyle(color: accent)),
                                        )
                                      : null,
                                );
                              },
                            );
                          }),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Đóng')),
                      ])
                    ]),
                  ),
                ),
              ),
            );
          },
        );
      });
    } catch (e, st) {
      // Debug: print exception and stacktrace to console, and show message in dialog
      // so it's easy to inspect while running on the emulator.
      debugPrint('Error loading danger snapshot: $e');
      debugPrintStack(stackTrace: st, label: 'DangerViewer stack:');
      if (!mounted) { return; }
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted) { return; }
        showDialog<void>(
          context: ctx,
          builder: (c) => AlertDialog(
            title: const Text('Lỗi'),
            content: SingleChildScrollView(child: Text('Không thể tải cảnh báo.\n\n${e.toString()}')),
            actions: [
              TextButton(onPressed: () => Navigator.of(c).pop(), child: const Text('Đóng')),
            ],
          ),
        );
      });
    }
  }

  

  void _navigateAndAddNote() async {
    final res = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _NoteEditorScreen()));
    if (res is String && res.isNotEmpty) { setState(() => _notes.add(res)); }
  }

  void _editNote(int idx) async {
    if (idx < 0 || idx >= _notes.length) { return; }
    final res = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => _NoteEditorScreen(initialText: _notes[idx])));
    if (res is String && res.isNotEmpty) { setState(() => _notes[idx] = res); }
  }

  void _deleteNote(int idx) {
    if (idx < 0 || idx >= _notes.length) { return; }
    setState(() => _notes.removeAt(idx));
  }
}

// ====== Small local widgets used by the dashboard

class _TripHeader extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onViewDanger;
  const _TripHeader({this.onBackPressed, this.onViewDanger});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 8),
      Center(child: Container(width: 18, height: 18, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle))),
      const SizedBox(height: 8),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
        child: Row(children: [
          IconButton(onPressed: onBackPressed, icon: const Icon(Icons.arrow_back, size: 28)),
          const Expanded(child: Center(child: Text('Bảng thông tin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)))),
          IconButton(onPressed: onViewDanger, icon: const Icon(Icons.info_outline)),
        ]),
      ),
    ]);
  }
}


class _TripTabs extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTabChanged;
  const _TripTabs({required this.activeIndex, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    Widget tab(String label, int idx) {
      final active = idx == activeIndex;
      return Expanded(
        child: GestureDetector(
          onTap: () => onTabChanged(idx),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: active ? kPrimaryGreen : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: active ? FontWeight.w700 : FontWeight.w500, color: active ? Colors.white : Colors.black54))),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: const Color(0xFFECE9E6), borderRadius: BorderRadius.circular(18)),
      child: Row(children: [tab('Lộ trình', 0), const SizedBox(width: 6), tab('Vật dụng', 1), const SizedBox(width: 6), tab('Ghi chú', 2)]),
    );
  }
}



class _ItemsTab extends StatelessWidget {
  final Plan? plan;
  const _ItemsTab({this.plan});

  @override
  Widget build(BuildContext context) {
    final items = plan?.equipmentList ?? [];

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.black38),
              SizedBox(height: 12),
              Text('Chưa có vật dụng trong kế hoạch này.', style: TextStyle(fontSize: 16, color: Colors.black54)),
            ],
          ),
        ),
      );
    }

    // Render plan items
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final name = item.name;
        final source = item.store ?? '';
        final price = item.price ?? '';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9FBE4),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text('PNG', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(source.toString(), style: const TextStyle(fontSize: 15)),
                    const SizedBox(height: 8),
                    Text(price.isNotEmpty ? price.toString() : '—', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.redAccent)),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
                  const Text('1', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.remove)),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}

class _NotesTab extends StatelessWidget {
  final List<String> notes;
  final void Function(int) onDeleteNote;

  final void Function(int) onEditNote;

  const _NotesTab({required this.notes, required this.onDeleteNote, required this.onEditNote});

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 80, left: 24, right: 24, top: 24),
        child: Center(child: Text('Chưa có ghi chú nào. Nhấn nút + để thêm.', style: TextStyle(color: Colors.black54))),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80, left: 24, right: 24, top: 24),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Dismissible(
          key: ValueKey('${note}_$index'),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) => onDeleteNote(index),
          background: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: Icon(Icons.delete, color: Colors.white),
              ),
            ),
          ),
          child: GestureDetector(
            onTap: () => onEditNote(index),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(note, style: const TextStyle(fontSize: 16, color: Colors.black87)),
            ),
          ),
        );
      },
    );
  }
}


class _RouteTab extends StatelessWidget {
  final Plan? plan;
  const _RouteTab({this.plan});

  @override
  Widget build(BuildContext context) {
    final routes = plan?.routes ?? [];
    if (plan == null) {
      return const Center(child: Text('Không có kế hoạch nào để xem trước.'));
    }
    if (routes.isEmpty) {
      return const Center(child: Text('Không có lộ trình được lưu trong kế hoạch này.'));
    }

    final r = routes.first;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (r.imageUrl != null && r.imageUrl!.isNotEmpty)
          Container(
            height: 180,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Colors.grey[200]),
            clipBehavior: Clip.hardEdge,
            child: Image.network(r.imageUrl!, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.photo))),
          ),
        const SizedBox(height: 12),
        Text(r.name ?? 'Lộ trình không tên', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(spacing: 12, runSpacing: 8, children: [
          if (r.distanceKm != null) Chip(label: Text('${r.distanceKm} km')),
          if (r.elevationGainM != null) Chip(label: Text('${r.elevationGainM} m độ cao')),
          if (r.durationDays != null) Chip(label: Text('${r.durationDays} ngày')),
        ]),
        const SizedBox(height: 12),
        if (plan?.description != null && plan!.description!.isNotEmpty) Text(plan!.description!),
      ],
    );
  }
}


class _NoteEditorScreen extends StatefulWidget {
  final String? initialText;
  const _NoteEditorScreen({this.initialText});

  @override
  State<_NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<_NoteEditorScreen> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctrl.text = widget.initialText ?? '';
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm ghi chú'), backgroundColor: kPrimaryGreen),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Expanded(child: TextField(controller: _ctrl, maxLines: null, expands: true, decoration: const InputDecoration(hintText: 'Nhập ghi chú...'))),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
            const SizedBox(width: 8),
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGreen),
                onPressed: () {
                  final t = _ctrl.text.trim();
                  Navigator.of(context).pop(t);
                },
                child: const Text('Lưu'))
          ])
        ]),
      ),
    );
  }
}
