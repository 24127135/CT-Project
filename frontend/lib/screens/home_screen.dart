import 'package:flutter/material.dart';
import 'tripinfopart1.dart'; // Step 1
import 'trip_list.dart'; // Trip List Screen
import 'fast_input.dart' as fast_input; // Fast Input Screen

const kBgColor = Color(0xFFF8F6F2);
const kForestGreen = Color(0xFF425E3C);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isPlanExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ====== HEADER GREEN + TITLE + DOT ======
              Container(
                width: double.infinity,
                color: kForestGreen,
                padding: const EdgeInsets.only(top: 16, bottom: 12),
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    // chấm đen
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.black,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'HOME PAGE',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        color: Colors.white.withOpacity(0.95),
                        shadows: const [
                          Shadow(
                            offset: Offset(0, 3),
                            blurRadius: 4,
                            color: Colors.black38,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),

              // ====== HERO IMAGE ======
              SizedBox(
                height: 180,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/sm_vuon_quoc_gia_bach_ma_ec2642a14c.jpg',
                      fit: BoxFit.cover,
                    ),
                    // nhẹ gradient cho dễ đọc text
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.0),
                            Colors.black.withOpacity(0.55),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Khám phá thiên nhiên Việt Nam',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Hãy bắt đầu hành trình',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ====== BODY CARDS ======
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
                child: Column(
                  children: [
                    // CARD 1 – LÊN KẾ HOẠCH (expand)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isPlanExpanded = !_isPlanExpanded;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.all(18),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: kForestGreen,
                            width: 1.1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildCardContent(
                              icon: Icons.map_outlined,
                              title: 'Lên kế hoạch',
                              subtitle: 'Nhập thông tin chuyến đi mới',
                            ),
                            if (_isPlanExpanded) ...[
                              const SizedBox(height: 16),
                              const Divider(
                                  height: 1, color: Color(0xFFE0DED6)),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildActionButton(
                                      'Tạo mới',
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                            const TripInfoScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildActionButton(
                                      'Nhập nhanh',
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                fast_input.TripListView(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),

                    // CARD 2 – CHUYẾN ĐI ĐÃ TẠO
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TripListView(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: const Color(0xFF9CA493), // viền nhạt hơn
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: _buildCardContent(
                          icon: Icons.receipt_long_outlined,
                          title: 'Chuyến đi đã tạo',
                          subtitle: 'Xem các kế hoạch đã lưu',
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // FOOTER TIP
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '💡',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 13,
                                color: kForestGreen,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Mẹo: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                  'Luôn kiểm tra thời tiết và chuẩn bị đầy đủ trang thiết bị trước khi lên đường!',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Nội dung 2 card chính
  Widget _buildCardContent({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: kForestGreen,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: kForestGreen,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9A978F),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Nút trắng trong card 1 khi expand
  Widget _buildActionButton(String text, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: kForestGreen.withOpacity(0.6),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: kForestGreen,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
