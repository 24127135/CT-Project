import 'package:flutter/material.dart';
import 'trip_dashboard_1.dart';

class Trip {
  final String title;
  final String subtitle;
  final String imageAsset;

  Trip({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
  });
}

class TripListView extends StatelessWidget {
  TripListView({super.key});

  final List<Trip> trips = [
    Trip(
      title: 'Núi chứa chan - Đồng Nai',
      subtitle:
      'Gần Sài Gòn. Có thể cắm trại qua đêm, view hoàng hôn/bình minh xuống đồng bằng rất thoáng và đẹp.',
      imageAsset: 'assets/images/image.jpg',
    ),
    Trip(
      title: 'Mũi Đôi - Khánh Hòa',
      subtitle:
      'Cắm trại sát biển (BBQ hải sản). Gần bãi cắm trại có suối nước ngọt để tắm. Gió biển thoáng mát.',
      imageAsset: 'assets/images/33Muidoihondau01.jpg',
    ),
    Trip(
      title: 'Pù Luông - Thanh Hóa',
      subtitle:
      'Thăm quan trải nghiệm ruộng bậc thang tuyệt đẹp, chụp ảnh săn mây buổi sáng sớm, trekking các cung đường đỉnh đồi đẹp.',
      imageAsset: 'assets/images/dia-chi-pu-luong.jpg',
    ),
    Trip(
      title: 'Vườn quốc gia Bạch Mã - Huế',
      subtitle:
      'Cung đi trong ngày, không cắm trại. Điểm nhấn là trekking qua Ngũ Hồ, nơi có 5 hồ nước trong vắt, cực kỳ lý tưởng để tắm.',
      imageAsset: 'assets/images/sm_vuon_quoc_gia_bach_ma_ec2642a14c.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Header có nút back + title
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
              child: ListView.builder(
                padding: const EdgeInsets.only(
                  bottom: 16,
                  left: 16,
                  right: 16,
                ),
                itemCount: trips.length,
                itemBuilder: (context, index) {
                  final trip = trips[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TripCard(trip: trip),
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

class TripCard extends StatelessWidget {
  final Trip trip;

  const TripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TripDashboard1()),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Ảnh nền
            AspectRatio(
              aspectRatio: 9 / 5, // chỉnh cho giống Figma
              child: Image.asset(
                trip.imageAsset,
                fit: BoxFit.cover,
              ),
            ),
            // Gradient tối dần ở dưới
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.05),
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
            ),
            // Text tiêu đề + mô tả
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    trip.subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
