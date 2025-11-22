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
  int _currentPage = 0;
  late final List<String> _imageUrls;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Sử dụng ảnh chính của route và thêm vài ảnh placeholder
    _imageUrls = [
      widget.route.imageUrl,
      'https://images.unsplash.com/photo-1501785888041-af3ef285b470?q=80&w=2070&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?q=80&w=2070&auto=format&fit=crop',
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Chiều cao khung thông tin (khoảng 50% màn hình)
    final sheetHeight = MediaQuery.of(context).size.height * 0.5;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          ),
        ),
      ),
      body: Stack(
        children: [
          // 1. Carousel Ảnh nền
          PageView.builder(
            controller: _pageController,
            itemCount: _imageUrls.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return Image.network(
                _imageUrls[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey),
              );
            },
          ),

          // 2. Bottom Info Sheet (Khung thông tin bên dưới)
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: sheetHeight,
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  // SingleChildScrollView giúp cuộn nếu nội dung quá dài
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tên Cung Đường
                        Text(
                          widget.route.name,
                          style: AppStyles.profileTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Địa điểm
                        Text(
                          widget.route.location,
                          style: AppStyles.profileSubtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 24),

                        // Hàng 1: Khoảng cách & Độ cao
                        Row(
                          children: [
                            Expanded(child: _buildStatBox("${widget.route.distanceKm}", "km", "Tổng chiều dài")),
                            const SizedBox(width: 16),
                            Expanded(child: _buildStatBox("${widget.route.elevationGainM}", "m", "Độ dốc tích lũy")),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Hàng 2: Thời gian & Địa hình
                        Row(
                          children: [
                            Expanded(child: _buildDurationStatBox(
                                widget.route.durationDays.toString(), "ngày",
                                widget.route.durationNights.toString(), "đêm",
                                "Thời gian ước tính"
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _buildStatBox(widget.route.terrain, "", "Địa hình")),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Button Bản đồ
                        CustomButton(
                          text: 'Bản đồ',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => InteractiveMapPage(route: widget.route)),
                            );
                          },
                          style: AppStyles.profileButton,
                          backgroundColor: AppColors.primaryGreen,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. Page Indicator (Chấm tròn chuyển trang)
          Positioned(
            bottom: sheetHeight + 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_imageUrls.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? AppColors.white : AppColors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET CON: Ô THÔNG TIN (TIÊU ĐỀ TRÊN - SỐ LIỆU DƯỚI) ---
  Widget _buildStatBox(String mainValue, String subValue, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Label (Tiêu đề nhỏ) nằm trên
        Text(
            label,
            style: AppStyles.statLabel.copyWith(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis
        ),
        const SizedBox(height: 4),

        // 2. Value (Số liệu to) nằm dưới
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: Text(
                mainValue,
                style: AppStyles.statValue.copyWith(fontSize: 22),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (subValue.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(subValue, style: AppStyles.statUnit.copyWith(fontSize: 14)),
              ),
          ],
        ),
      ],
    );
  }

  // --- WIDGET CON: Ô THỜI GIAN (TIÊU ĐỀ TRÊN - SỐ LIỆU DƯỚI) ---
  Widget _buildDurationStatBox(String days, String daysLabel, String nights, String nightsLabel, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Label nằm trên
        Text(label, style: AppStyles.statLabel.copyWith(fontSize: 12), maxLines: 1),
        const SizedBox(height: 4),

        // 2. Value nằm dưới
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(days, style: AppStyles.statValue.copyWith(fontSize: 22)),
            Padding(
              padding: const EdgeInsets.only(left: 2, right: 4),
              child: Text(daysLabel, style: AppStyles.statUnit.copyWith(fontSize: 14)),
            ),
            Text(nights, style: AppStyles.statValue.copyWith(fontSize: 22)),
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Text(nightsLabel, style: AppStyles.statUnit.copyWith(fontSize: 14)),
            ),
          ],
        ),
      ],
    );
  }
}