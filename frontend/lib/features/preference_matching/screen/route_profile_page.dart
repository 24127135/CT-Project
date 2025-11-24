import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/features/preference_matching/models/route_model.dart';
import 'package:frontend/features/preference_matching/screen/interactive_map_page.dart';
import 'package:frontend/utils/app_colors.dart';
import 'package:frontend/utils/app_styles.dart';
import 'package:frontend/widgets/custom_button.dart';

class RouteProfilePage extends StatefulWidget {
  final RouteModel route;

  const RouteProfilePage({super.key, required this.route});

  @override
  State<RouteProfilePage> createState() => _RouteProfilePageState();
}

class _RouteProfilePageState extends State<RouteProfilePage> {
  late final PageController _pageController;
  late final List<String> _imageUrls;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // --- LOGIC XỬ LÝ ẢNH TỐI ƯU ---
    List<String> images = [];

    // 1. Luôn lấy ảnh đại diện làm ảnh bìa đầu tiên (Quan trọng)
    if (widget.route.imageUrl.isNotEmpty) {
      images.add(widget.route.imageUrl);
    }

    // 2. Sau đó mới thêm các ảnh trong gallery
    if (widget.route.gallery.isNotEmpty) {
      images.addAll(widget.route.gallery);
    }

    // 3. Nếu không có ảnh nào -> Dùng ảnh fallback
    if (images.isEmpty) {
      images.add('https://images.unsplash.com/photo-1501785888041-af3ef285b470?q=80');
    }

    // Xóa ảnh trùng lặp
    _imageUrls = images.toSet().toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color activeGreen = const Color(0xFF66BB6A);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. ẢNH NỀN FULL MÀN HÌNH
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _imageUrls.length,
              itemBuilder: (context, index) {
                return Image.network(
                  _imageUrls[index],
                  fit: BoxFit.cover,
                  // Hiển thị màu xám trong lúc tải ảnh
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(color: Colors.grey[900]);
                  },
                  errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[900]),
                );
              },
            ),
          ),

          // 2. NÚT BACK
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),
          ),

          // 3. THẺ THÔNG TIN (GLASSMORPHISM)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TÊN & ĐỊA ĐIỂM
                          Text(
                            widget.route.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.route.location,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // GRID THÔNG SỐ
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildNumberStat("${widget.route.distanceKm}", "km", "Tổng chiều dài"),
                                    const SizedBox(height: 20),
                                    _buildDurationStat(
                                        widget.route.durationDays.toString(),
                                        widget.route.durationNights.toString(),
                                        "Quãng thời gian\nước tính"
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildNumberStat("${widget.route.elevationGainM}", "m", "Độ dốc tích lũy"),
                                    const SizedBox(height: 20),
                                    _buildTerrainStat("Địa hình", widget.route.terrain),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // NÚT BẢN ĐỒ
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => InteractiveMapPage(route: widget.route)),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: activeGreen,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Bản đồ',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET: SỐ LIỆU (Số trên - Chữ dưới)
  Widget _buildNumberStat(String value, String unit, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1),
            ),
            const SizedBox(width: 2),
            Text(unit, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13, fontWeight: FontWeight.w400)),
      ],
    );
  }

  // WIDGET: THỜI GIAN (Số trên - Chữ dưới)
  Widget _buildDurationStat(String days, String nights, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(days, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
            const Text("ngày ", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            Text(nights, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
            const Text("đêm", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13, height: 1.2)),
      ],
    );
  }

  // WIDGET: ĐỊA HÌNH (Tiêu đề trên - Nội dung dưới)
  Widget _buildTerrainStat(String label, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14, height: 1.3),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}