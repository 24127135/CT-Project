import 'package:flutter/material.dart';
import 'trip_dashboard_2.dart';
import 'trip_dashboard_3.dart';

const kBgColor = Color(0xFFF8F6F2);
const kPrimaryGreen = Color(0xFF38C148); // chỉnh lại cho khớp Figma

class TripDashboard1 extends StatelessWidget {
  const TripDashboard1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: Column(
          children: [
            const _TripHeader(),
            const _TripTabs(activeIndex: 0),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    _MapSection(),
                    const SizedBox(height: 16),
                    _RouteInfoSection(),
                    const SizedBox(height: 24),
                    const _NoteSection(),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            // TODO: confirm route
                          },
                          child: const Text(
                            'XÁC NHẬN LỘ TRÌNH',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _TripHeader extends StatelessWidget {
  const _TripHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 12),
      child: Column(
        children: [
          // chấm đen trên cùng
          const SizedBox(height: 4),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.black,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Bảng thông tin',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48), // để cân với nút back
            ],
          ),
        ],
      ),
    );
  }
}

class _TripTabs extends StatelessWidget {
  final int activeIndex; // 0: Lộ trình, 1: Vật dụng, 2: Ghi chú
  const _TripTabs({required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    Widget buildTab(String label, int index) {
      final bool isActive = index == activeIndex;
      return Expanded(
        child: GestureDetector(
          onTap: () {
            if (index == activeIndex) return;
            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const TripDashboard1(),
                ),
              );
            } else if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const TripDashboard2(),
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const TripDashboard3(),
                ),
              );
            }
          },
          child: Container(
            height: 44,
            margin: EdgeInsets.only(
              left: index == 0 ? 24 : 4,
              right: index == 2 ? 24 : 4,
            ),
            decoration: BoxDecoration(
              color: isActive ? kPrimaryGreen : const Color(0xFFE5E1DB),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        buildTab('Lộ trình', 0),
        buildTab('Vật dụng', 1),
        buildTab('Ghi chú', 2),
      ],
    );
  }
}

class _MapSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Stack(
        children: [
          // ảnh map
          AspectRatio(
            aspectRatio: 9 / 6,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                image: const DecorationImage(
                  // TODO: thay bằng Image.asset('assets/images/image 24.png')
                  image: AssetImage('assets/images/image 24.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // nút Tùy chỉnh
          Positioned(
            left: 16,
            bottom: 16,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: const [
                  Icon(Icons.edit, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Tùy chỉnh',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ],
              ),
            ),
          ),
          // nút 3D
          Positioned(
            right: 16,
            bottom: 16,
            child: Container(
              width: 56,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFE7E5D9),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.layers, size: 28),
                  SizedBox(height: 8),
                  Text(
                    '3D',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteInfoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding:
            EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Text(
              'Pù Luông - Thanh Hóa',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '25 km · 700 m gain · Est. 2 days',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // elevation chart
          Container(
            margin:
            const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            height: 80,
            color: Colors.grey[200],
            child: const Center(
              child: Text('Elevation chart placeholder'),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteSection extends StatelessWidget {
  const _NoteSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Note',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Lorem ipsum dolor sit amet consectetur. Aenean pellentesque tellus senectus vitae et tempor dui.',
            style: TextStyle(fontSize: 15, height: 1.4),
          ),
        ],
      ),
    );
  }
}
