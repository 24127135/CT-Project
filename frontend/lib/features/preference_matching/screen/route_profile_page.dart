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

  // Temporary list of images for the carousel
  late final List<String> _imageUrls;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Use the route's main image and add some placeholders
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
          // Swipable Background Image Carousel
          PageView.builder(
            controller: _pageController,
            itemCount: _imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Image.network(
                _imageUrls[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
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
                  height: MediaQuery.of(context).size.height * 0.4,
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.route.name, style: AppStyles.profileTitle),
                          const SizedBox(height: 8),
                          Text(widget.route.location, style: AppStyles.profileSubtitle),
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
                              Expanded(child: _buildDurationStatBox(widget.route.durationDays.toString(), "ngày", widget.route.durationNights.toString(), "đêm", "Quãng thời gian\nước tính")),
                              const SizedBox(width: 16),
                              Expanded(child: _buildStatBox(widget.route.terrain, "", "Địa hình")),
                            ],
                          ),
                        ],
                      ),

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
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Page Indicator
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.4 + 10,
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

  Widget _buildStatBox(String mainValue, String subValue, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(mainValue, style: AppStyles.statValue.copyWith(fontSize: 28)),
            if (subValue.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(subValue, style: AppStyles.statUnit.copyWith(fontSize: 14)),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: AppStyles.statLabel.copyWith(fontSize: 12), maxLines: 2),
      ],
    );
  }

  Widget _buildDurationStatBox(String days, String daysLabel, String nights, String nightsLabel, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(days, style: AppStyles.statValue.copyWith(fontSize: 28)),
            Padding(
              padding: const EdgeInsets.only(left: 2, right: 4),
              child: Text(daysLabel, style: AppStyles.statUnit.copyWith(fontSize: 14)),
            ),
            Text(nights, style: AppStyles.statValue.copyWith(fontSize: 28)),
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
