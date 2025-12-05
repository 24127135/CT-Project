import 'package:flutter/material.dart';
import 'package:frontend/screens/about_us.dart';
import 'package:frontend/screens/edit_profile.dart';
import 'package:frontend/screens/support.dart';
import 'package:frontend/screens/welcome_view.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            // ===== HEADER + PROFILE CHÈN LÊN =====
            SizedBox(
              height: 210, // 140 header + phần avatar trồi xuống
              child: Stack(
                clipBehavior: Clip.none, // cho avatar tràn khỏi header
                children: [
                  // HEADER GRADIENT + BACK + TITLE
                  SizedBox(
                    height: 140,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 140,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              // GIỮ NGUYÊN GRADIENT NHƯ BẠN ĐANG XÀI
                              begin: Alignment(1, 1),
                              end: Alignment(-1, -1),
                              colors: [
                                Color(0xFF53BB30), // Highlight
                                Color(0xFF0D1711),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 8,
                          top: 40,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Color(0xFFF8F5F2),
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const Positioned(
                          top: 40,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Text(
                              'Settings',
                              style: TextStyle(
                                color: Color(0xFFF8F5F2),
                                fontSize: 24,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w800,
                                height: 0.83,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // PROFILE HEADER trồi xuống khỏi header
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: -60,
                    child: _ProfileHeader(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 72), // chừa khoảng trống dưới avatar

            // ===== LIST SETTINGS + TEXT CUỐI =====
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            width: 1,
                            color: Color(0xFFC2CDBF), // Xanh-lá-1
                          ),
                        ),
                      ),
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _SettingsItem(
                            icon: Icons.person_outline,
                            label: 'Tùy chỉnh hồ sơ',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const EditProfileScreen()),
                              );
                            },
                          ),
                          _SettingsItem(
                            icon: Icons.support_agent_outlined,
                            label: 'Cần hỗ trợ',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SupportScreen()),
                              );
                            },
                          ),
                          _SettingsItem(
                            icon: Icons.rate_review_outlined,
                            label: 'Đánh giá',
                            onTap: () {
                              int rating = 0;
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return AlertDialog(
                                        title: Text('Đánh giá ứng dụng'),
                                        content: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: List.generate(5, (index) {
                                            return IconButton(
                                              icon: Icon(
                                                index < rating
                                                    ? Icons.star
                                                    : Icons.star_border,
                                                color: Colors.amber,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  rating = index + 1;
                                                });
                                              },
                                            );
                                          }),
                                        ),
                                        actions: [
                                          TextButton(
                                            child: Text('Từ chối'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text('Gửi'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Cảm ơn bạn đã đánh giá $rating sao!'),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                          _SettingsItem(
                            icon: Icons.info_outline,
                            label: 'Về chúng tôi',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AboutUsScreen()),
                              );
                            },
                          ),
                          _SettingsItem(
                            icon: Icons.logout,
                            label: 'Đăng xuất',
                            isDestructive: true,
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext dialogContext) {
                                  return AlertDialog(
                                    title: const Text('Đăng xuất'),
                                    content: const Text(
                                        'Đăng xuất khỏi tài khoản hiện tại?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Từ chối'),
                                        onPressed: () {
                                          Navigator.of(dialogContext).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Đăng xuất'),
                                        onPressed: () {
                                          Navigator.of(dialogContext).pop();
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const WelcomeView()),
                                            (Route<dynamic> route) => false,
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Padding(
                    padding: EdgeInsets.only(bottom: 0.0),
                    child: SizedBox(
                      width: 263,
                      child: Text(
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
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====== WIDGET PROFILE HEADER ======

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 120,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 112,
                height: 112,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(width: 4, color: Colors.white),
                ),
                child: const CircleAvatar(
                  backgroundColor: Color(0xFFD9D9D9),
                  // backgroundImage: AssetImage('assets/avatar.png'),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 4,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF314158),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(width: 2, color: Colors.white),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Nguyễn Sơn Lộc',
          style: TextStyle(
            color: Color(0xFF0A0A0A),
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w800,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'sonloc@gmail.com',
          style: TextStyle(
            color: Color(0xFF697282),
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// ====== WIDGET ITEM TRONG LIST SETTINGS ======

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final VoidCallback? onTap;

  const _SettingsItem({
    Key? key,
    required this.icon,
    required this.label,
    this.isDestructive = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color textColor =
    isDestructive ? const Color(0xFFFA2B36) : const Color(0xFF354152);

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: textColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: Color(0xFF354152),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
