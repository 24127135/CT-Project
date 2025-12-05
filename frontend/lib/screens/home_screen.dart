import 'package:flutter/material.dart';
import 'package:frontend/screens/setting.dart';
import 'tripinfopart1.dart';
import 'fast_input.dart';
import 'trip_list.dart' as trip_list;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool _showPlanButtons = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      body: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: 412,
                  height: 917,
                  child: Stack(
                    children: [
                      // ẢNH NỀN --------------------------------------------------
                      Positioned(
                        left: -12,
                        top: 0,
                        child: SizedBox(
                          width: 424,
                          height: 919,
                          child: Image.network(
                            'https://static.minhtuanmobile.com/uploads/editer/images/hinh-nen-dien-thoai-thien-nhien-tuyet-sac-4k-02.webp',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // HOME INDICATOR --------------------------------------------
                      Positioned(
                        left: 6,
                        top: 883,
                        child: SizedBox(
                          width: 400,
                          height: 34,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 272,
                                top: 26,
                                child: Container(
                                  transform: Matrix4.identity()..rotateZ(3.14),
                                  width: 144,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF404040),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // GRADIENT ĐẦU TRANG ----------------------------------------
                      Positioned(
                        left: -1,
                        top: 0,
                        child: Container(
                          width: 413,
                          height: 119,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(-0.01, 1.02),
                              end: Alignment(1.00, 0.32),
                              colors: [
                                Color(0xFF486A40),
                                Color(0xFF0E1711),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // SHAPE XANH QUANH INFO USER -------------------------------
                      Positioned(
                        left: 75,
                        top: 70,
                        child: Container(
                          width: 302,
                          height: 40,
                          decoration: const ShapeDecoration(
                            color: Color(0xFF486A40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(94),
                                topRight: Radius.circular(94),
                                bottomLeft: Radius.circular(94),
                                bottomRight: Radius.circular(5),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 77.45,
                        top: 117.52,
                        child: Container(
                          width: 233.48,
                          height: 36.38,
                          decoration: const ShapeDecoration(
                            color: Color(0xFF859C80),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(94),
                                bottomLeft: Radius.circular(94),
                                bottomRight: Radius.circular(80),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 127,
                        top: 90,
                        child: Container(
                          width: 237,
                          height: 42,
                          decoration: const ShapeDecoration(
                            color: Color(0xFFC2CDBF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(701),
                                topRight: Radius.circular(754),
                                bottomLeft: Radius.circular(701),
                                bottomRight: Radius.circular(741),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // AVATAR ----------------------------------------------------
                      Positioned(
                        left: 36,
                        top: 49,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SettingsScreen()),
                            );
                          },
                          child: Container(
                            width: 117.59,
                            height: 117.59,
                            decoration: const ShapeDecoration(
                              color: Color(0xFFD9D9D9),
                              shape: OvalBorder(
                                side: BorderSide(
                                  width: 7,
                                  color: Color(0xFF0B3800),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // TÊN + CÂU HỎI + EMAIL ------------------------------------
                      const Positioned(
                        left: 159,
                        top: 100,
                        child: Text(
                          'Nguyễn Sơn Lộc',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF070707),
                            fontSize: 20,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 149,
                        top: 74,
                        child: Text(
                          'Bạn đã chinh phục bao nhiêu đỉnh núi?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 145,
                        top: 136,
                        child: Text(
                          'nsloc2419@clc.fitus.edu.vn',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),

                      // TEXT INTRO NHỎ TRÊN ĐẦU ----------------------------------
                      const Positioned(
                        left: 75,
                        top: 11,
                        child: SizedBox(
                          width: 263,
                          height: 28,
                          child: Text(
                            'App Trek Guide được tạo ra bởi nhóm Five Point Crew\nLà một đồ án đại học\nKhông có giá trị thương mại!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ),

                      // SUBTITLE --------------------------------------------------
                      const Positioned(
                        left: 11,
                        top: 302,
                        child: SizedBox(
                          width: 236,
                          height: 43,
                          child: Text(
                            'Khám phá thiên nhiên Việt Nam',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 4),
                                  blurRadius: 4,
                                  color: Color(0x40000000),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),

                      // TITLE -----------------------------------------------------
                      const Positioned(
                        left: 11,
                        top: 323,
                        child: SizedBox(
                          width: 271,
                          height: 43,
                          child: Text(
                            'Hãy bắt đầu hành trình',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w900,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 4),
                                  blurRadius: 16,
                                  color: Color(0x40000000),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ====== KHỐI GIỮA: LÊN KẾ HOẠCH + CHUYẾN ĐI ĐÃ TẠO =======
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 360,
                        child: Column(
                          children: [
                            _PlanCard(
                              expanded: _showPlanButtons,
                              onToggle: () {
                                setState(() {
                                  _showPlanButtons = !_showPlanButtons;
                                });
                              },
                              onCreateNew: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const TripInfoScreen(),
                                  ),
                                );
                              },
                              onQuickInput: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                    const FastInputListView(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            _CreatedTripCard(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        trip_list.TripListView(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ================== WIDGET CARD "LÊN KẾ HOẠCH" ==================

class _PlanCard extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onCreateNew;
  final VoidCallback onQuickInput;

  const _PlanCard({
    required this.expanded,
    required this.onToggle,
    required this.onCreateNew,
    required this.onQuickInput,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 23),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: onToggle,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // phần trắng trên: icon + text
                Padding(
                  padding:
                  const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 62.64,
                        height: 62.64,
                        decoration: BoxDecoration(
                          color: const Color(0xFF486A40),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/icon/plan.png',
                            width: 32,
                            height: 32,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lên kế hoạch',
                              style: TextStyle(
                                color: Color(0xFF486A40),
                                fontSize: 20,
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Nhập thông tin chuyến đi mới',
                              style: TextStyle(
                                color: Color(0xFF486A40),
                                fontSize: 16,
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // phần xanh + 2 nút (chỉ hiện khi expanded = true)
                if (expanded)
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF53BB30),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(15),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: onCreateNew,
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Tạo mới',
                                style: TextStyle(
                                  color: Color(0xFF486A40),
                                  fontSize: 18,
                                  fontFamily: 'Kanit',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: onQuickInput,
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Nhập nhanh',
                                style: TextStyle(
                                  color: Color(0xFF486A40),
                                  fontSize: 18,
                                  fontFamily: 'Kanit',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================== WIDGET CARD "CHUYẾN ĐI ĐÃ TẠO" ==================

class _CreatedTripCard extends StatelessWidget {
  final VoidCallback onTap;

  const _CreatedTripCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: SizedBox(
            height: 109,
            child: Row(
              children: [
                const SizedBox(width: 16),
                Container(
                  width: 62.64,
                  height: 62.64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF486A40),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/icon/trip.png',
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Chuyến đi đã tạo',
                        style: TextStyle(
                          color: Color(0xFF486A40),
                          fontSize: 20,
                          fontFamily: 'Kanit',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Xem các kế hoạch đã lưu',
                        style: TextStyle(
                          color: Color(0xFF486A40),
                          fontSize: 16,
                          fontFamily: 'Kanit',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}