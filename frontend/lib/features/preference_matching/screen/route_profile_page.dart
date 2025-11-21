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
    // Tăng chiều cao lên khoảng 48% - 50% màn hình để đủ chỗ hiển thị
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
          // Carousel Ảnh nền
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

          // Bottom Info Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: sheetHeight, // Sửa chiều cao
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 20), // Giảm padding bottom chút
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  // THÊM: SingleChildScrollView để cuộn nếu nội dung quá dài
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.route.name,
                          style: AppStyles.profileTitle,
                          maxLines: 2, // Giới hạn 2 dòng
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.route.location,
                          style: AppStyles.profileSubtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 24),

                        // Stats Grid
                        Row(
                          children: [
                            Expanded(child: _buildStatBox("${widget.route.distanceKm}", "km", "Tổng chiều dài")),
                            const SizedBox(width: 16),
                            Expanded(child: _buildStatBox("${widget.route.elevationGainM}", "m", "Độ dốc tích lũy")),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildDurationStatBox(
                                widget.route.durationDays.toString(), "ngày",
                                widget.route.durationNights.toString(), "đêm",
                                "Thời gian ước tính"
                            )),
                            const SizedBox(width: 16),
                            // Chỗ này dễ bị lỗi overflow ngang nhất, cần xử lý kỹ trong _buildStatBox
                            Expanded(child: _buildStatBox(widget.route.terrain, "", "Địa hình")),
                          ],
                        ),

                        const SizedBox(height: 32), // Khoảng cách trước nút bấm

                        // Button
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
                        // Thêm khoảng trống dưới cùng để không bị sát mép màn hình quá
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Page Indicator (Chấm tròn chuyển trang)
          Positioned(
            // Đặt vị trí dựa trên chiều cao mới của Sheet
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

  // Widget helper đã được nâng cấp để chống tràn chữ ngang
  Widget _buildStatBox(String mainValue, String subValue, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            // Flexible giúp text tự xuống dòng hoặc cắt bớt nếu quá dài
            Flexible(
              child: Text(
                mainValue,
                style: AppStyles.statValue.copyWith(fontSize: 24), // Giảm font size một chút nếu cần
                maxLines: 1,
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
        const SizedBox(height: 4),
        Text(
            label,
            style: AppStyles.statLabel.copyWith(fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis
        ),
      ],
    );
  }

  Widget _buildDurationStatBox(String days, String daysLabel, String nights, String nightsLabel, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap( // Dùng Wrap để an toàn hơn Row nếu màn hình quá nhỏ
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(days, style: AppStyles.statValue.copyWith(fontSize: 24)),
            Padding(
              padding: const EdgeInsets.only(left: 2, right: 4),
              child: Text(daysLabel, style: AppStyles.statUnit.copyWith(fontSize: 14)),
            ),
            Text(nights, style: AppStyles.statValue.copyWith(fontSize: 24)),
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Text(nightsLabel, style: AppStyles.statUnit.copyWith(fontSize: 14)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: AppStyles.statLabel.copyWith(fontSize: 12), maxLines: 2),
      ],
    );
  }
}