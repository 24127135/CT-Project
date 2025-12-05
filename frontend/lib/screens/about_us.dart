import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  Color get _greenDark => const Color(0xFF0B3800);

  BoxDecoration get _cardDecoration => BoxDecoration(
    color: const Color(0xFFF8F8F8),
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
      BoxShadow(
        color: Color(0x3F000000),
        blurRadius: 4,
        offset: Offset(0, 4),
      ),
    ],
  );

  BoxDecoration get _iconDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(13),
    boxShadow: const [
      BoxShadow(
        color: Color(0x3F000000),
        blurRadius: 9.1,
        offset: Offset(0, 2),
        spreadRadius: 4,
      )
    ],
  );

  Widget _buildBenefitCard({
    required double width,
    required IconData icon,
    required String text,
  }) {
    return SizedBox(
      width: width,
      height: 150,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Card
          Positioned.fill(
            top: 24,
            child: Container(
              decoration: _cardDecoration,
              padding: const EdgeInsets.fromLTRB(12, 30, 12, 16),
              child: Center(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          // Icon box
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 52,
                height: 52,
                decoration: _iconDecoration,
                child: Icon(
                  icon,
                  color: _greenDark,
                  size: 26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterNote() {
    return const Text(
      'App Trek Guide được tạo ra bởi nhóm Five Point Crew\n'
          'Là một đồ án đại học\n'
          'Không có giá trị thương mại!',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xFF040404),
        fontSize: 10,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w300,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Nội dung chính
          Column(
            children: [
              // Header gradient
              Container(
                height: 140,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(1, 1),
                    end: Alignment(-1, -1),
                    colors: [
                      Color(0xFF53BB30), // Highlight
                      Color(0xFF0D1711),
                    ],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Về chúng tôi',
                          style: const TextStyle(
                            color: Color(0xFFF8F5F2),
                            fontSize: 24,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w800,
                            height: 1.0,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 8,
                        top: 4,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.of(context).maybePop();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Body scroll
              Expanded(
                child: SingleChildScrollView(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth =
                          (constraints.maxWidth - 16) / 2; // 2 cột, 16 spacing

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),
                          // FIVE-POINT CREW
                          Text(
                            'FIVE-POINT CREW',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _greenDark,
                              fontSize: 24,
                              fontFamily: 'MonumentExtended',
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Giải pháp mang lại',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF314D24),
                              fontSize: 8,
                              fontStyle: FontStyle.italic,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'App chúng tôi hướng đến \nnhững mục đích sau',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF0B3800),
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // 4 cards
                          Wrap(
                            spacing: 16,
                            runSpacing: 24,
                            alignment: WrapAlignment.center,
                            children: [
                              _buildBenefitCard(
                                width: cardWidth,
                                icon: Icons.checklist_rtl_rounded,
                                text:
                                'Tự tin chuẩn bị chuyến trekking một cách bài bản',
                              ),
                              _buildBenefitCard(
                                width: cardWidth,
                                icon: Icons.access_time_rounded,
                                text:
                                'Tiết kiệm thời gian tìm hiểu và lên kế hoạch',
                              ),
                              _buildBenefitCard(
                                width: cardWidth,
                                icon: Icons.safety_check_rounded,
                                text:
                                'Giảm thiểu rủi ro và đề xuất phù hợp nhu cầu',
                              ),
                              _buildBenefitCard(
                                width: cardWidth,
                                icon: Icons.hiking_rounded,
                                text: 'Cá nhân hóa chuyến đi trekking',
                              ),
                            ],
                          ),

                          const SizedBox(height: 48),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 12),
                child: _buildFooterNote(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
