import 'dart:math';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:frontend/services/gemini_service.dart';
// --- IMPORT CHO 3D (MapLibre) ---
import 'package:maplibre_gl/maplibre_gl.dart';

// --- IMPORT CHO 2D (Flutter Map - Dùng alias 'fmap' để không trùng tên LatLng) ---
import 'package:flutter_map/flutter_map.dart' as fmap;
import 'package:latlong2/latlong.dart' as fcoords;

import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/features/preference_matching/models/route_model.dart';
// app_colors and app_styles were unused here; imports removed during analyzer cleanup
import 'package:frontend/widgets/custom_button.dart';
import 'package:frontend/providers/trip_provider.dart';
import 'package:frontend/screens/pec.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/utils/notification.dart';

class InteractiveMapPage extends StatefulWidget {
  final RouteModel route;
  const InteractiveMapPage({super.key, required this.route});

  @override
  State<InteractiveMapPage> createState() => _InteractiveMapPageState();
}

class _InteractiveMapPageState extends State<InteractiveMapPage> {
  // Controller cho 3D
  MapLibreMapController? map3DController;

  // Controller cho 2D
  final fmap.MapController map2DController = fmap.MapController();

  bool _isLoading = false;
  bool _isMapReady = false;

  // Trạng thái: True = Hiện Map 3D, False = Hiện Map 2D
  bool _is3DMode = false; // Mặc định vào là 2D (Esri)

  // MapTiler key: prefer --dart-define, else flutter_dotenv
  final String _apiKey = (() {
    const fromDefine = String.fromEnvironment('MAPTILER_KEY');
    if (fromDefine.isNotEmpty) return fromDefine;
    return dotenv.env['MAPTILER_KEY'] ?? 'your_maptiler_key_here';
  })();

  String get _style3DUrl => "https://api.maptiler.com/maps/outdoor-v2/style.json?key=$_apiKey";

  List<FlSpot> _elevationSpots = [];

  // Dữ liệu tách biệt cho 2 loại bản đồ
  List<LatLng> _coords3D = [];
  List<fcoords.LatLng> _coords2D = [];
  List<Map<String, dynamic>> _waypointsData = [];

  @override
  void initState() {
    super.initState();
    _prepareData();
    _generateSimulatedElevation();
  }

  // --- 1. CHUẨN BỊ DỮ LIỆU ---
  Future<void> _prepareData() async {
    try {
      final supabase = Supabase.instance.client;

      // A. Lấy đường đi
      final routeResponse = await supabase
          .from('routes')
          .select('path_coordinates')
          .eq('id', widget.route.id)
          .single();

      if (routeResponse['path_coordinates'] != null) {
        final List<dynamic> rawCoords = routeResponse['path_coordinates'];

        // Tạo dữ liệu cho 3D (MapLibre LatLng)
        _coords3D = rawCoords.map((c) => LatLng(c[0], c[1])).toList();

        // Tạo dữ liệu cho 2D (Latlong2 LatLng)
        _coords2D = rawCoords.map((c) => fcoords.LatLng(c[0], c[1])).toList();
      }

      // B. Lấy Waypoints
      final wptResponse = await supabase
          .from('route_waypoints')
          .select('*')
          .eq('route_id', widget.route.id);

      setState(() {
        _waypointsData = List<Map<String, dynamic>>.from(wptResponse);
        _isMapReady = true;
      });

    } catch (e) {
      debugPrint("🔴 Lỗi tải data: $e");
    }
  }

  // --- 2. CẤU HÌNH MAP 3D (MapLibre) ---
  void _onMap3DCreated(MapLibreMapController controller) {
    map3DController = controller;
  }

  Future<void> _onStyle3DLoaded() async {
    if (map3DController == null) return;

    // 1. Vẽ đường 3D
    if (_coords3D.isNotEmpty) {
      await map3DController!.addLine(LineOptions(
        geometry: _coords3D,
        lineColor: "#ff0000",
        lineWidth: 4.0,
        lineOpacity: 0.9,
      ));

      // Camera 3D
      await map3DController!.animateCamera(CameraUpdate.newLatLngBounds(
          _bounds3D(_coords3D), left: 50, right: 50, top: 100, bottom: 50
      ));
      await Future.delayed(const Duration(milliseconds: 500));
      await map3DController!.animateCamera(CameraUpdate.tiltTo(70.0));
    }

    // 2. Tạo ảnh marker và vẽ cho 3D
    await _add3DMarkers();
  }

  Future<void> _add3DMarkers() async {
    await map3DController!.addImage("icon-summit", await _createMarkerImage(Icons.terrain, Colors.brown));
    await map3DController!.addImage("icon-water", await _createMarkerImage(Icons.water_drop, Colors.blue));
    await map3DController!.addImage("icon-danger", await _createMarkerImage(Icons.warning_rounded, Colors.red));
    await map3DController!.addImage("icon-camp", await _createMarkerImage(Icons.night_shelter, Colors.green));
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
    // Start/End 3D
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

  // --- 3. WIDGET MAP 2D (Flutter Map - ESRI - Widget Marker) ---
  Widget _buildMap2D() {
    if (_coords2D.isEmpty) return const Center(child: CircularProgressIndicator());

    return fmap.FlutterMap(
      mapController: map2DController,
      options: fmap.MapOptions(
        initialCameraFit: fmap.CameraFit.bounds(
          bounds: fmap.LatLngBounds.fromPoints(_coords2D),
          padding: const EdgeInsets.all(50),
        ),
      ),
      children: [
        // Lớp nền ESRI WORLD TOPO (Đẹp, chi tiết đường mòn)
        fmap.TileLayer(
          urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}',
          userAgentPackageName: 'com.trekking.app',
        ),

        // Lớp vẽ đường
        fmap.PolylineLayer(
          polylines: [
            fmap.Polyline(
              points: _coords2D,
              color: Colors.redAccent,
              strokeWidth: 4.0,
            ),
          ],
        ),

        // Lớp Marker (Dùng Widget Flutter tùy chỉnh - Icon cũ)
        fmap.MarkerLayer(
          markers: [
            // Marker START
            fmap.Marker(
              point: _coords2D.first,
              width: 100, height: 60,
              child: _build2DLabelMarker("START", Icons.circle, Colors.green),
            ),
            // Marker END
            fmap.Marker(
              point: _coords2D.last,
              width: 100, height: 60,
              child: _build2DLabelMarker("END", Icons.flag, Colors.red),
            ),
            // Các Marker Waypoints
            ..._waypointsData.map((wpt) {
              return fmap.Marker(
                point: fcoords.LatLng(wpt['latitude'], wpt['longitude']),
                width: 120, height: 80, // Đủ rộng để chứa text
                child: _build2DDetailMarker(wpt),
              );
            }),
          ],
        ),
      ],
    );
  }

  // Helper: Widget Marker cho 2D (Y hệt hình cũ)
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
      onTap: () => _showWaypointInfo(wpt),
      child: Column(
        children: [
          // Bong bóng chứa tên
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
          // Icon tròn ở dưới
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

  // --- CÁC HÀM PHỤ TRỢ KHÁC ---
  void _toggle3D() {
    setState(() {
      _is3DMode = !_is3DMode;
    });
  }

  // Hàm vẽ ảnh cho 3D
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
    final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
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

  void _generateSimulatedElevation() {
    final points = 50; final random = Random(); List<FlSpot> spots = [];
    double currentElevation = 500; double maxGain = widget.route.elevationGainM.toDouble();
    for (int i = 0; i < points; i++) {
      double change = (random.nextDouble() - 0.45) * (maxGain / 8);
      currentElevation += change; if (currentElevation < 0) currentElevation = 0;
      double distance = (widget.route.distanceKm / points) * i;
      spots.add(FlSpot(distance, currentElevation));
    }
    _elevationSpots = spots;
  }

  // --- LOGIC XÁC NHẬN: BẬT LẠI GEMINI CHECKLIST ---
  // --- LOGIC XÁC NHẬN: BẬT LẠI GEMINI CHECKLIST ---
  Future<void> _confirmRoute(BuildContext context) async {
    setState(() => _isLoading = true);
    final BuildContext ctx = context;
    final navigator = Navigator.of(ctx);
    try {
      final tripProvider = Provider.of<TripProvider>(context, listen: false);
      final supabase = Supabase.instance.client;

      // 1. Lấy danh sách thiết bị
      final equipmentResponse = await supabase.from('equipment').select('id, name, category');
      final List<Map<String, dynamic>> equipmentList = List<Map<String, dynamic>>.from(equipmentResponse);

      // 2. Thông tin người dùng
      // SỬA LỖI: Dùng widget.route.difficulty (hoặc chuỗi mặc định nếu model chưa có field này)
      final userProfile = {
        "difficulty": "Vừa phải", // Tạm thời để cứng để tránh lỗi model, hoặc dùng widget.route.difficulty
        "group_size": 2,
        "interests": ["Cắm trại", "Trekking"],
        "duration": widget.route.durationDays
      };

      // 3. Gọi Gemini (Đã có import nên sẽ hết lỗi)
      final geminiService = GeminiService();
      Map<String, dynamic> aiGeneratedChecklist = {};

      try {
        aiGeneratedChecklist = await geminiService.generateChecklist(
          route: widget.route,
          userProfile: userProfile,
          allEquipment: equipmentList,
        );
      } catch (aiError) {
        // Inform user but continue with empty checklist
        if (mounted) NotificationService.showInfo('AI checklist không khả dụng, tiếp tục lưu mặc định.');
      }

      // 4. Lưu vào Database
      await tripProvider.confirmRouteForPlan(
          widget.route.id,
          checklist: aiGeneratedChecklist
      );

      if (!mounted) return;
      // Notify user then navigate
      NotificationService.showSuccess('Đã cập nhật chuyến đi. Chuẩn bị PEC...');
      navigator.push(MaterialPageRoute(builder: (_) => const PECScreen()));

    } catch (e) {
      if (!mounted) return;
      NotificationService.showError('Lỗi: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showWaypointInfo(Map<String, dynamic> wpt) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- SỬA LỖI HEADING2 TẠI ĐÂY ---
            Text(wpt['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(wpt['description'] ?? 'Không có mô tả'),
            const SizedBox(height: 16),
            CustomButton(text: "Đóng", onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // --- LOGIC CHUYỂN ĐỔI MAP ---
          // Nếu _is3DMode = True -> Hiện MapLibre (Outdoor, 3D)
          // Nếu _is3DMode = False -> Hiện FlutterMap (Esri, 2D, Icon xịn)
          _is3DMode
              ? MapLibreMap(
            styleString: _style3DUrl,
            onMapCreated: _onMap3DCreated,
            onStyleLoadedCallback: _onStyle3DLoaded,
            initialCameraPosition: const CameraPosition(target: LatLng(21.0, 105.8), zoom: 10.0),
            rotateGesturesEnabled: true, tiltGesturesEnabled: true,
          )
              : _buildMap2D(), // Widget 2D Esri

          if (!_isMapReady && !_is3DMode)
            Container(color: Colors.white, child: const Center(child: CircularProgressIndicator())),

          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10, left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
            ),
          ),

          // Toggle Button 2D/3D
          Positioned(
            top: MediaQuery.of(context).padding.top + 10, right: 16,
            child: GestureDetector(
              onTap: _toggle3D,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black87, borderRadius: BorderRadius.circular(30),
                  boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: Row(children: [
                  Icon(_is3DMode ? Icons.map : Icons.view_in_ar, size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(_is3DMode ? "Chế độ 2D" : "Chế độ 3D", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ]),
              ),
            ),
          ),

          // Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.45, minChildSize: 0.2, maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                decoration: const BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: Container(width: 40, height: 4, color: Colors.grey[300], margin: const EdgeInsets.symmetric(vertical: 10))),
                      Text(widget.route.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('${widget.route.distanceKm} km • ${widget.route.elevationGainM}m gain • ${widget.route.durationDays} days', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(height: 20),
                      const Text("Biểu đồ độ cao:", style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      SizedBox(height: 100, child: _buildElevationChart()),
                      const SizedBox(height: 32),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), padding: const EdgeInsets.symmetric(vertical: 16)), onPressed: () => _confirmRoute(context), child: const Text('XÁC NHẬN LỘ TRÌNH', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)))),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildElevationChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false), titlesData: const FlTitlesData(show: false), borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: _elevationSpots, isCurved: true, color: Colors.black87, barWidth: 2, dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [Colors.green.withValues(alpha:0.3), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          ),
        ], lineTouchData: const LineTouchData(enabled: false),
      ),
    );
  }
}