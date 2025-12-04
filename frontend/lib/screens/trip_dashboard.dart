// ignore_for_file: unused_element_parameter
import 'dart:convert';

import 'dart:math';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/logger.dart';

// --- CÁC SERVICE CỦA BẠN ---
import '../services/supabase_db_service.dart';
import '../services/plan_service.dart';
import '../models/plan.dart';
import '../services/danger_labels.dart';
import '../services/gemini_service.dart';

// --- IMPORT CHO MAP & CHART ---
import 'package:maplibre_gl/maplibre_gl.dart'; // 3D Map
import 'package:flutter_map/flutter_map.dart' as fmap; // 2D Map
import 'package:latlong2/latlong.dart' as fcoords; // Toạ độ cho 2D Map
import 'package:fl_chart/fl_chart.dart'; // Biểu đồ

const kBgColor = Color(0xFFF8F6F2);
const kPrimaryGreen = Color(0xFF38C148);

class TripDashboard extends StatefulWidget {
  final int? planId;

  const TripDashboard({super.key, this.planId});

  @override
  State<TripDashboard> createState() => _TripDashboardState();
}

class _TripDashboardState extends State<TripDashboard> {
  final SupabaseDbService _db = SupabaseDbService();
  final GeminiService _geminiService = GeminiService();
  late final PlanService _planService = PlanService(db: _db);

  Plan? _latestPlan;
  int _activeIndex = 0;
  final PageController _pageController = PageController();
  final List<String> _notes = [];

  Map<String, Map<String, dynamic>> _equipmentDetails = {};

  String? _aiRouteNote;
  bool _isLoadingNote = false;

  @override
  void initState() {
    super.initState();
    // Tải dữ liệu ngay khi màn hình mở
    SchedulerBinding.instance.addPostFrameCallback((_) => _initSafetyCheck());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _launchBuyLink(String itemName, String? dbLink) async {
    final Uri url;
    if (dbLink != null && dbLink.isNotEmpty) {
      url = Uri.parse(dbLink);
    } else {
      final query = Uri.encodeComponent(itemName);
      url = Uri.parse('https://shopee.vn/search?keyword=$query');
    }
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      AppLogger.e('TripDashboard', 'Error launching URL: ${e.toString()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không thể mở liên kết mua hàng")),
        );
      }
    }
  }

  Future<void> _fetchEquipmentDetails(Plan plan) async {
    final eqMap = plan.personalizedEquipmentList;
    if (eqMap == null || eqMap.isEmpty) return;

    final Set<String> ids = {};
    eqMap.forEach((key, value) {
      if (value is List) {
        for (var item in value) {
          if (item['id'] != null) ids.add(item['id'].toString());
        }
      }
    });

    if (ids.isEmpty) return;

    try {
      final response = await Supabase.instance.client
          .from('equipment')
          .select('id, image_url, buy_link')
          .inFilter('id', ids.toList());

      final Map<String, Map<String, dynamic>> details = {};
      for (var row in response) {
        details[row['id'].toString()] = row;
      }

      if (mounted) {
        setState(() {
          _equipmentDetails = details;
        });
      }
    } catch (e) {
      AppLogger.e('TripDashboard', 'Error fetching equipment details: ${e.toString()}');
    }
  }

  Future<void> _generateAiNote(Plan plan) async {
    if (plan.routes.isEmpty) return;

    final route = plan.routes.first;

    setState(() => _isLoadingNote = true);

      final raw = await _geminiService.generateRouteNote(
        route.name ?? '',
        plan.location
      );

    String display = raw;
    // Defensive: AI service may return structured JSON (e.g. { "note": "..." })
    try {
      if (display.trim().startsWith('{') || display.trim().startsWith('[')) {
        final decoded = jsonDecode(display);
        if (decoded is Map) {
          if (decoded.containsKey('note') && decoded['note'] is String) {
            display = decoded['note'] as String;
          } else if (decoded.containsKey('text') && decoded['text'] is String) {
            display = decoded['text'] as String;
          } else if (decoded.containsKey('content') && decoded['content'] is String) {
            display = decoded['content'] as String;
          } else {
            // Try to find first string value
            final firstStr = decoded.values.firstWhere((v) => v is String, orElse: () => null);
            if (firstStr is String) {
              display = firstStr;
            } else {
              display = decoded.toString();
            }
          }
        } else if (decoded is List && decoded.isNotEmpty) {
          // join list items into readable text
          display = decoded.map((e) => e.toString()).join('\n');
        }
      }
    } catch (e) {
      // ignore JSON parse errors and use raw string
      AppLogger.e('TripDashboard', 'AI note parse error: ${e.toString()}');
    }

    if (mounted) {
      setState(() {
        _aiRouteNote = display.trim();
        _isLoadingNote = false;
      });
    }
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
                  // Tab 1: Route (Truyền plan vào đây, nếu plan null thì nó hiện loading hoặc fake)
                  _RouteTab(
                      plan: _latestPlan,
                      aiNote: _aiRouteNote,
                      isLoadingNote: _isLoadingNote
                  ),
                  // Tab 2: Equipment
                  _ItemsTab(
                    plan: _latestPlan,
                    equipmentDetails: _equipmentDetails,
                    onBuyPressed: _launchBuyLink,
                  ),
                  // Tab 3: Notes
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

    // Show loading
    showDialog<void>(
      context: ctx,
      barrierDismissible: false,
      builder: (c) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisSize: MainAxisSize.min, children: const [CircularProgressIndicator(), SizedBox(width: 16), Text('Đang tải dữ liệu...')]),
        ),
      ),
    );

    try {
      Plan? targetPlan;
      if (widget.planId != null) {
        final allPlans = await _planService.getPlans();
        try {
          targetPlan = allPlans.firstWhere((p) => p.id == widget.planId);
        } catch (e) {
          targetPlan = await _planService.getLatestPlan();
        }
      } else {
        targetPlan = await _planService.getLatestPlan();
      }

      if (!mounted) {
        if (navigator.canPop()) navigator.pop();
        return;
      }

      // Update State: Plan đã tải xong
      setState(() => _latestPlan = targetPlan);

      if (targetPlan != null) {
        _fetchEquipmentDetails(targetPlan);
        // Check weather and possibly save dangers snapshot
        try {
          await _checkWeatherAndSave(targetPlan);
        } catch (e) {
          AppLogger.e('TripDashboard', 'Weather check failed: ${e.toString()}');
        }
        _generateAiNote(targetPlan);
      }

      // Check Danger
      try {
        final snapshot = await _db.getLatestDangerSnapshot();
        if (snapshot != null) {
          final pid = _latestPlan?.id;
          if (pid != null) {
            final ack = await _isAcknowledgedForPlanWithSnapshot(pid, snapshot);
            if (navigator.canPop()) navigator.pop();
            if (!ack) {
              final message = snapshot.toString();
              if (!mounted) return;
              await _showDangerWarning(navigator, message);
            }
            return;
          }
        }
        if (navigator.canPop()) navigator.pop();
      } catch (_) {
        if (navigator.canPop()) navigator.pop();
      }
    } catch (err) {
      try {
        if (navigator.canPop()) navigator.pop();
      } catch (_) {}
    }
  }

  Future<void> _acknowledgePlan(int planId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ack_plan_$planId', true);
  }
  Future<bool> _isAcknowledgedForPlanWithSnapshot(int planId, dynamic snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    // If the global plan ack exists, treat as acknowledged
    if (prefs.getBool('ack_plan_$planId') == true) return true;

    // If snapshot is empty/null then not acknowledged
    if (snapshot == null) return false;

    // If snapshot is a map, ensure every danger key has been acknowledged
    if (snapshot is Map) {
      for (final k in snapshot.keys) {
        final key = _dangerStorageKey(planId, k.toString());
        if (prefs.getBool(key) != true) return false;
      }
      return true;
    }

    // If snapshot is a list, check each index key
    if (snapshot is List) {
      for (var i = 0; i < snapshot.length; i++) {
        final key = _dangerStorageKey(planId, i.toString());
        if (prefs.getBool(key) != true) return false;
      }
      return true;
    }

    // For other snapshot types, use a generic 'message' key
    final key = _dangerStorageKey(planId, 'message');
    return prefs.getBool(key) == true;
  }

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
      // If the user clears a per-danger acknowledgement, also clear the
      // global plan acknowledgement so the warning dialog can reappear.
      try {
        await prefs.remove('ack_plan_$planId');
      } catch (_) {}
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
        entries.add(MapEntry('message', snapshot));
      }

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
    } catch (e) {
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

  Future<void> _checkWeatherAndSave(Plan plan) async {
    final loc = plan.location;
    if (loc == null || loc.trim().isEmpty) return;

    double? lat;
    double? lon;
    try {
      final geocodeUrl = Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(loc)}&format=json&limit=1');
      final geores = await http.get(geocodeUrl, headers: {'User-Agent': 'CT-Project-App'});
      if (geores.statusCode == 200) {
        final decoded = jsonDecode(geores.body) as List<dynamic>?;
        if (decoded != null && decoded.isNotEmpty) {
          final first = decoded.first as Map<String, dynamic>;
          lat = double.tryParse(first['lat']?.toString() ?? '');
          lon = double.tryParse(first['lon']?.toString() ?? '');
        }
      }
    } catch (e) {
      AppLogger.e('TripDashboard', 'Geocoding failed: ${e.toString()}');
    }

    if (lat == null || lon == null) return;

    int? planId = plan.id;
    DateTime? startDate;
    int durationDays = 1;
    if (planId != null) {
      final planRow = await _db.getPlanById(planId);
      if (planRow != null) {
        try {
          final sd = planRow['start_date']?.toString();
          if (sd != null && sd.isNotEmpty) {
            startDate = DateTime.tryParse(sd);
          }
        } catch (_) {}

        try {
          final d = planRow['duration_days'];
          if (d is int) {
            durationDays = d;
          } else if (d is String) {
            durationDays = int.tryParse(d) ?? durationDays;
          }
        } catch (_) {}
      }
    }
    startDate ??= DateTime.now().toUtc();
    final endDate = startDate.add(Duration(days: durationDays));

    final startStr = startDate.toIso8601String().split('T').first;
    final endStr = endDate.toIso8601String().split('T').first;

    final weatherUrl = Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,windspeed_10m_max&timezone=UTC&start_date=$startStr&end_date=$endStr');

    Map<String, dynamic>? weatherJson;
    try {
      final wres = await http.get(weatherUrl);
      if (wres.statusCode == 200) weatherJson = jsonDecode(wres.body) as Map<String, dynamic>?;
    } catch (e) {
      AppLogger.e('TripDashboard', 'Weather fetch failed: ${e.toString()}');
    }
    if (weatherJson == null) return;

    final Map<String, dynamic> snapshot = {};
    try {
      final daily = weatherJson['daily'] as Map<String, dynamic>?;
      if (daily != null) {
        final tempsMax = List<dynamic>.from(daily['temperature_2m_max'] ?? []);
        final tempsMin = List<dynamic>.from(daily['temperature_2m_min'] ?? []);
        final precSum = List<dynamic>.from(daily['precipitation_sum'] ?? []);
        final windMax = List<dynamic>.from(daily['windspeed_10m_max'] ?? []);

        bool heavyRain = precSum.any((v) => (v ?? 0) is num && (v as num) > 20);
        bool strongWind = windMax.any((v) => (v ?? 0) is num && (v as num) > 15);
        bool extremeHeat = tempsMax.any((v) => (v ?? 0) is num && (v as num) > 40);
        bool extremeCold = tempsMin.any((v) => (v ?? 0) is num && (v as num) < -10);

        if (heavyRain) snapshot['heavy_rain'] = true;
        if (strongWind) snapshot['strong_wind'] = true;
        if (extremeHeat) snapshot['extreme_heat'] = true;
        if (extremeCold) snapshot['extreme_cold'] = true;

        if (snapshot.isNotEmpty) {
          snapshot['source'] = 'open-meteo';
          snapshot['latitude'] = lat;
          snapshot['longitude'] = lon;
          snapshot['start_date'] = startStr;
          snapshot['end_date'] = endStr;
          snapshot['raw'] = daily;
        }
      }
    } catch (e) {
      AppLogger.e('TripDashboard', 'Weather analysis error: ${e.toString()}');
    }

    if (snapshot.isNotEmpty && planId != null) {
      try {
        await _db.saveDangerSnapshotForPlan(planId, snapshot);
        AppLogger.d('TripDashboard', 'Saved danger snapshot for plan $planId');
      } catch (e) {
        AppLogger.e('TripDashboard', 'Failed to save danger snapshot: ${e.toString()}');
      }
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

class _ItemsTab extends StatefulWidget {
  final Plan? plan;
  final Map<String, Map<String, dynamic>> equipmentDetails;
  final Function(String, String?) onBuyPressed;

  const _ItemsTab({
    this.plan,
    required this.equipmentDetails,
    required this.onBuyPressed,
  });

  @override
  State<_ItemsTab> createState() => _ItemsTabState();
}

class _ItemsTabState extends State<_ItemsTab> {
  final Set<String> _checked = {};
  bool _loadingLocal = true;

  String? get _planKey => widget.plan?.id != null ? 'local_checklist_plan_${widget.plan!.id}' : null;

  @override
  void initState() {
    super.initState();
    _loadLocalChecklist();
  }

  Future<void> _loadLocalChecklist() async {
    final key = _planKey;
    if (key == null) {
      setState(() => _loadingLocal = false);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(key) ?? [];
    setState(() {
      _checked.addAll(list);
      _loadingLocal = false;
    });
  }

  Future<void> _saveLocalChecklist() async {
    final key = _planKey;
    if (key == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, _checked.toList());
  }

  void _toggleItemChecked(String id, bool? value) {
    setState(() {
      if (value == true) {
        _checked.add(id);
      } else {
        _checked.remove(id);
      }
    });
    _saveLocalChecklist();
  }

  void _clearLocalChecklist() async {
    final key = _planKey;
    if (key == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    setState(() => _checked.clear());
  }

  @override
  Widget build(BuildContext context) {
    final equipmentMap = widget.plan?.personalizedEquipmentList ?? {};

    if (equipmentMap.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.checklist_rtl_rounded, size: 64, color: Colors.black12),
              SizedBox(height: 12),
              Text(
                'Chưa có danh sách vật dụng.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final entries = equipmentMap.entries.toList();
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 80, top: 0),
        children: entries.asMap().entries.map((mapEntry) {
          final idx = mapEntry.key;
          final entry = mapEntry.value;
          String category = entry.key;
          List<dynamic> items = entry.value is List ? entry.value : [];

          if (items.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 4, height: 18,
                      decoration: BoxDecoration(color: kPrimaryGreen, borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        category.toUpperCase(),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1.0),
                      ),
                    ),
                    if (idx == 0) ...[
                      if (_loadingLocal) const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
                      TextButton(onPressed: _clearLocalChecklist, child: const Text('Xóa đánh dấu')),
                    ]
                  ],
                ),
              ),
              ...items.map((item) => _buildSingleItem(item)),
              const SizedBox(height: 8),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSingleItem(dynamic itemData) {
    final Map<String, dynamic> item = Map<String, dynamic>.from(itemData);
    final String name = item['name'] ?? 'Vật dụng';
    final int quantity = item['quantity'] ?? 1;
    final String? reason = item['reason'];
    final id = item['id'].toString();

    String? imageUrl;
    String? buyLink;
    if (widget.equipmentDetails.containsKey(id)) {
      imageUrl = widget.equipmentDetails[id]?['image_url'];
      buyLink = widget.equipmentDetails[id]?['buy_link'];
    }

    final priceRaw = item['price'];
    String priceStr = '';
    if (priceRaw != null) {
      priceStr = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(priceRaw);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Local checklist checkbox
              Padding(
                padding: const EdgeInsets.only(top: 2.0, right: 8.0),
                child: Checkbox(
                  value: _checked.contains(id),
                  onChanged: (v) => _toggleItemChecked(id, v),
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                )
                    : const Icon(Icons.hiking, color: Colors.grey),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300)
                          ),
                          child: Text("x$quantity", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        )
                      ],
                    ),

                    if (priceStr.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(priceStr, style: const TextStyle(fontSize: 14, color: Colors.redAccent, fontWeight: FontWeight.w600)),
                    ],

                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => widget.onBuyPressed(name, buyLink),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.withAlpha(128)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.shopping_cart_outlined, size: 14, color: Colors.deepOrange),
                            const SizedBox(width: 4),
                            Text(
                                "Mua ngay",
                                style: TextStyle(fontSize: 11, color: Colors.deepOrange, fontWeight: FontWeight.bold)
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (reason != null && reason.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.auto_awesome, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reason,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.brown.shade700,
                        fontStyle: FontStyle.italic,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}

class _RouteTab extends StatefulWidget {
  final Plan? plan;
  final String? aiNote;
  final bool isLoadingNote;

  const _RouteTab({
    super.key,
    this.plan,
    this.aiNote,
    this.isLoadingNote = false
  });

  @override
  State<_RouteTab> createState() => _RouteTabState();
}

class _RouteTabState extends State<_RouteTab> with AutomaticKeepAliveClientMixin {
  // --- Controller & State ---
  MapLibreMapController? map3DController;
  final fmap.MapController map2DController = fmap.MapController();

  bool _is3DMode = false;
  bool _isMapLoading = true;

  // MapTiler API key: prefer --dart-define, else flutter_dotenv
  final String _apiKey = (() {
    const fromDefine = String.fromEnvironment('MAPTILER_KEY');
    if (fromDefine.isNotEmpty) return fromDefine;
    return dotenv.env['MAPTILER_KEY'] ?? 'your_maptiler_key_here';
  })();

  String get _style3DUrl => "https://api.maptiler.com/maps/outdoor-v2/style.json?key=$_apiKey";

  // Dữ liệu
  List<LatLng> _coords3D = []; // LatLng của MapLibre
  List<fcoords.LatLng> _coords2D = []; // LatLng của latlong2
  List<Map<String, dynamic>> _waypointsData = [];
  List<FlSpot> _elevationSpots = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _prepareData();
  }

  // 🔥 QUAN TRỌNG: Lắng nghe sự thay đổi của Plan (Khi load xong)
  @override
  void didUpdateWidget(covariant _RouteTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nếu plan thay đổi (từ null -> có data), chạy lại prepareData
    if (widget.plan?.id != oldWidget.plan?.id) {
      _prepareData();
    }
  }

  Future<void> _prepareData() async {
    try {
      final routes = widget.plan?.routes ?? [];
      int? routeId = routes.isNotEmpty ? routes.first.id : null;

      // Nếu không có Route ID (Plan null), chưa làm gì cả (chờ data)
      if (routeId == null) {
        if (widget.plan != null) {
          // Plan có nhưng route rỗng -> Dùng Fake
          _useFakeData();
        }
        return;
      }

      List<dynamic> rawCoords = [];

      // A. Lấy tọa độ từ DB
      final supabase = Supabase.instance.client;
      final routeResponse = await supabase
          .from('routes')
          .select('path_coordinates')
          .eq('id', routeId)
          .maybeSingle();

      if (routeResponse != null && routeResponse['path_coordinates'] != null) {
        rawCoords = routeResponse['path_coordinates'];
      }

      // Fallback
      if (rawCoords.isEmpty) {
        _useFakeData();
        return;
      }

      // B. Cập nhật State
      if (mounted) {
        setState(() {
          _coords3D = rawCoords.map((c) => LatLng(c[0].toDouble(), c[1].toDouble())).toList();
          _coords2D = rawCoords.map((c) => fcoords.LatLng(c[0].toDouble(), c[1].toDouble())).toList();
          _isMapLoading = false;
        });

        _generateSimulatedElevation(
            widget.plan?.routes.firstOrNull?.distanceKm ?? 10,
            widget.plan?.routes.firstOrNull?.elevationGainM ?? 1600
        );
      }

      // C. Lấy Waypoints
      final wptResponse = await supabase
          .from('route_waypoints')
          .select('*')
          .eq('route_id', routeId);

      if (mounted) {
        setState(() {
          _waypointsData = List<Map<String, dynamic>>.from(wptResponse);
        });
      }
    } catch (e) {
      // _prepareData error suppressed to avoid noisy logs
      if (mounted) setState(() => _isMapLoading = false);
    }
  }

  void _useFakeData() {
    final fake = [
      [22.335, 103.840], [22.338, 103.842], [22.342, 103.845],
      [22.345, 103.848], [22.340, 103.855], [22.330, 103.860],
    ];
    setState(() {
      _coords3D = fake.map((c) => LatLng(c[0], c[1])).toList();
      _coords2D = fake.map((c) => fcoords.LatLng(c[0], c[1])).toList();
      _isMapLoading = false;
    });
  }

  // --- 2. CẤU HÌNH MAP 3D (MapLibre) ---
  void _onMap3DCreated(MapLibreMapController controller) {
    map3DController = controller;
  }

  Future<void> _onStyle3DLoaded() async {
    if (map3DController == null || _coords3D.isEmpty) return;

    // Vẽ đường đỏ
    await map3DController!.addLine(LineOptions(
      geometry: _coords3D,
      lineColor: "#ff0000",
      lineWidth: 4.0,
      lineOpacity: 0.9,
    ));

    // Camera animate
    await map3DController!.animateCamera(CameraUpdate.newLatLngBounds(
        _bounds3D(_coords3D), left: 50, right: 50, top: 50, bottom: 50
    ));

    // Tilt hiệu ứng 3D
    await Future.delayed(const Duration(milliseconds: 500));
    await map3DController!.animateCamera(CameraUpdate.tiltTo(60.0));

    // Thêm các marker 3D
    await _add3DMarkers();
  }

  Future<void> _add3DMarkers() async {
    await map3DController!.addImage("icon-summit", await _createMarkerImage(Icons.terrain, Colors.brown));
    await map3DController!.addImage("icon-water", await _createMarkerImage(Icons.water_drop, Colors.blue));
    await map3DController!.addImage("icon-danger", await _createMarkerImage(Icons.warning_rounded, Colors.red));
    await map3DController!.addImage("icon-camp", await _createMarkerImage(Icons.night_shelter, Colors.green));

    // Start/End icons 3D
    await map3DController!.addImage("icon-start", await _createMarkerImage(Icons.circle, Colors.greenAccent));
    await map3DController!.addImage("icon-end", await _createMarkerImage(Icons.flag, Colors.redAccent));

    for (var wpt in _waypointsData) {
      String iconName = "icon-summit";
      if (wpt['type'] == 'water') iconName = "icon-water";
      if (wpt['type'] == 'danger') iconName = "icon-danger";
      if (wpt['type'] == 'campsite') iconName = "icon-camp";

      await map3DController!.addSymbol(SymbolOptions(
        geometry: LatLng(wpt['latitude'], wpt['longitude']),
        iconImage: iconName, iconSize: 0.5,
        textField: wpt['name'], textOffset: const Offset(0, 1.8),
        textSize: 12.0, textHaloColor: "#ffffff", textHaloWidth: 1.5,
      ));
    }

    if (_coords3D.isNotEmpty) {
      await map3DController!.addSymbol(SymbolOptions(
        geometry: _coords3D.first, iconImage: "icon-start", iconSize: 0.6,
        textField: "START", textOffset: const Offset(0, 1.5), textColor: "#00AA00", textHaloColor: "#ffffff", textHaloWidth: 2.0,
      ));
      await map3DController!.addSymbol(SymbolOptions(
        geometry: _coords3D.last, iconImage: "icon-end", iconSize: 0.6,
        textField: "END", textOffset: const Offset(0, 1.5), textColor: "#FF0000", textHaloColor: "#ffffff", textHaloWidth: 2.0,
      ));
    }
  }

  LatLngBounds _bounds3D(List<LatLng> list) {
    double? minLat, maxLat, minLng, maxLng;
    for (final latLng in list) {
      minLat = (minLat == null) ? latLng.latitude : min(minLat, latLng.latitude);
      maxLat = (maxLat == null) ? latLng.latitude : max(maxLat, latLng.latitude);
      minLng = (minLng == null) ? latLng.longitude : min(minLng, latLng.longitude);
      maxLng = (maxLng == null) ? latLng.longitude : max(maxLng, latLng.longitude);
    }
    return LatLngBounds(southwest: LatLng(minLat!, minLng!), northeast: LatLng(maxLat!, maxLng!));
  }

  Future<Uint8List> _createMarkerImage(IconData iconData, Color bgColor) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const int size = 100; final double radius = size / 2;

    final Paint shadowPaint = Paint()..color = Colors.black.withAlpha(102)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
    canvas.drawCircle(Offset(radius, radius + 3), radius, shadowPaint);

    final Paint borderPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(radius, radius), radius, borderPaint);

    final Paint bgPaint = Paint()..color = bgColor;
    canvas.drawCircle(Offset(radius, radius), radius - 6, bgPaint);

    final TextPainter textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(fontSize: size * 0.55, fontFamily: iconData.fontFamily, color: Colors.white, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(radius - textPainter.width / 2, radius - textPainter.height / 2));
    final ui.Image image = await pictureRecorder.endRecording().toImage(size, size);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  // --- 3. CẤU HÌNH MAP 2D (Flutter Map - ESRI - Giao diện Interactive) ---

  Widget _build2DLabelMarker(String label, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 4)],
            border: Border.all(color: color, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
        Icon(Icons.arrow_drop_down, color: color, size: 24),
      ],
    );
  }

  Widget _build2DDetailMarker(Map<String, dynamic> wpt) {
    Color color = Colors.blue;
    IconData icon = Icons.place;

    if (wpt['type'] == 'summit') { color = Colors.brown; icon = Icons.terrain; }
    if (wpt['type'] == 'danger') { color = Colors.red; icon = Icons.warning_rounded; }
    if (wpt['type'] == 'campsite') { color = Colors.green[700]!; icon = Icons.night_shelter; }

    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(230),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              wpt['name'],
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [const BoxShadow(color: Colors.black38, blurRadius: 3, offset: Offset(0, 2))],
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildMap2D() {
    if (_coords2D.isEmpty) return const Center(child: Text("Không có dữ liệu bản đồ"));

    return fmap.FlutterMap(
      mapController: map2DController,
      options: fmap.MapOptions(
          initialCameraFit: fmap.CameraFit.bounds(
            bounds: fmap.LatLngBounds.fromPoints(_coords2D),
            padding: const EdgeInsets.all(40),
          ),
          // 🔥 QUAN TRỌNG: Chỉ Zoom khi Map đã sẵn sàng
          onMapReady: () {
            if (_coords2D.isNotEmpty) {
              map2DController.fitCamera(
                fmap.CameraFit.bounds(
                  bounds: fmap.LatLngBounds.fromPoints(_coords2D),
                  padding: const EdgeInsets.all(40),
                ),
              );
            }
          }
      ),
      children: [
        fmap.TileLayer(
          // ESRI WORLD TOPO LAYER (Giao diện chuẩn Interactive Map)
          urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}',
          userAgentPackageName: 'com.trekking.app',
        ),
        fmap.PolylineLayer(
          polylines: [
            fmap.Polyline(points: _coords2D, color: Colors.redAccent, strokeWidth: 4.0),
          ],
        ),
        fmap.MarkerLayer(
          markers: [
            fmap.Marker(
              point: _coords2D.first,
              width: 100, height: 60,
              child: _build2DLabelMarker("START", Icons.circle, Colors.green),
            ),
            fmap.Marker(
              point: _coords2D.last,
              width: 100, height: 60,
              child: _build2DLabelMarker("END", Icons.flag, Colors.red),
            ),
            ..._waypointsData.map((wpt) {
              return fmap.Marker(
                point: fcoords.LatLng(wpt['latitude'], wpt['longitude']),
                width: 120, height: 80,
                child: _build2DDetailMarker(wpt),
              );
            }),
          ],
        ),
      ],
    );
  }

  void _generateSimulatedElevation(double distKm, int gainM) {
    final points = 50; final random = Random(); List<FlSpot> spots = [];
    double currentElevation = 500; double maxGain = gainM.toDouble();
    for (int i = 0; i < points; i++) {
      double change = (random.nextDouble() - 0.45) * (maxGain / 8);
      currentElevation += change; if (currentElevation < 0) currentElevation = 0;
      double distance = (distKm / points) * i;
      spots.add(FlSpot(distance, currentElevation));
    }
    setState(() {
      _elevationSpots = spots;
    });
  }

  // --- UI CHÍNH ---
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final routes = widget.plan?.routes ?? [];
    if (widget.plan == null || routes.isEmpty) {
      // Khi đang load data hoặc plan lỗi
      return const Center(child: CircularProgressIndicator());
    }
    final r = routes.first;

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        SizedBox(
          height: 400,
          child: Stack(
            children: [
              if (_isMapLoading)
                const Center(child: CircularProgressIndicator())
              else if (_is3DMode)
                MapLibreMap(
                  styleString: _style3DUrl,
                  onMapCreated: _onMap3DCreated,
                  onStyleLoadedCallback: _onStyle3DLoaded,
                  initialCameraPosition: const CameraPosition(target: LatLng(21.0, 105.8), zoom: 10.0),
                  rotateGesturesEnabled: true, tiltGesturesEnabled: true,
                )
              else
                _buildMap2D(),

              // Nút Toggle 2D/3D Style đen
              Positioned(
                top: 16, right: 16,
                child: GestureDetector(
                  onTap: () => setState(() => _is3DMode = !_is3DMode),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black87, borderRadius: BorderRadius.circular(30),
                      boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                    child: Row(children: [
                      Icon(_is3DMode ? Icons.map : Icons.view_in_ar, size: 18, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(_is3DMode ? "2D" : "3D", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                    ]),
                  ),
                ),
              ),

              // Nút Tùy chỉnh (Giữ nguyên vị trí nhưng update style đen)
              Positioned(
                top: 16, left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(153),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.tune, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text("Tùy chỉnh", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // 2. INFO SECTION
        Container(
          transform: Matrix4.translationValues(0, -20, 0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                r.name ?? 'Lộ trình không tên',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, height: 1.2),
              ),
              const SizedBox(height: 8),

              Text(
                '${r.distanceKm ?? 0} km • ${r.elevationGainM ?? 0} m gain • Est. ${r.durationDays ?? 1} days',
                style: TextStyle(fontSize: 16, color: Colors.grey[700], fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),

              const Text("Biểu đồ độ cao", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 12),
              SizedBox(
                height: 150,
                width: double.infinity,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (spots) => spots.map((s) => LineTooltipItem('${s.y.toInt()}m', const TextStyle(color: Colors.white))).toList(),
                        )
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _elevationSpots.isNotEmpty ? _elevationSpots : [const FlSpot(0,0), const FlSpot(1,0)],
                        isCurved: true,
                        color: Colors.black87,
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [kPrimaryGreen.withAlpha(77), Colors.white],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("0.0 km", style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text("${r.distanceKm ?? 10} km", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 20, color: Colors.purple),
                  const SizedBox(width: 8),
                  const Text("Thông tin AI gợi ý", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),

              if (widget.isLoadingNote)
                const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple.withAlpha(13),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple.withAlpha(26)),
                  ),
                  child: Text(
                    widget.aiNote ?? "Không có thông tin bổ sung.",
                    style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
                  ),
                ),
            ],
          ),
        ),
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

class _NotesTab extends StatelessWidget {
  final List<String> notes;
  final void Function(int) onDeleteNote;
  final void Function(int) onEditNote;

  const _NotesTab({
    required this.notes,
    required this.onDeleteNote,
    required this.onEditNote
  });

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.note_add_outlined, size: 64, color: Colors.black12),
              SizedBox(height: 12),
              Text(
                'Chưa có ghi chú nào.\nNhấn nút + để thêm.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80, left: 16, right: 16, top: 16),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Dismissible(
          key: ValueKey('${note}_$index'),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) => onDeleteNote(index),
          background: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: GestureDetector(
            onTap: () => onEditNote(index),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Text(note, style: const TextStyle(fontSize: 15, color: Colors.black87)),
            ),
          ),
        );
      },
    );
  }
}