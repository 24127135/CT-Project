import 'package:flutter/material.dart';
import 'home_screen.dart'; // Tạm thời dẫn về đây

class WaitingScreen extends StatefulWidget {
  const WaitingScreen({super.key});

  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {

  @override
  void initState() {
    super.initState();
    // --- LOGIC CHỜ GIẢ LẬP ---
    // Đợi 3 giây (hoặc thời gian bạn muốn), sau đó chuyển trang
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // Chuyển đến HomeScreen (Tạm thời thay cho Preference Matching)

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomePage()),
              (Route<dynamic> route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: const Color(0xFFF5F5F0), // Màu nền kem nhạt (giống ảnh)
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Vòng tròn Loading tùy chỉnh
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                strokeWidth: 8, // Độ dày nét vẽ (làm dày lên giống ảnh)
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                backgroundColor: Colors.grey.shade300,
                strokeCap: StrokeCap.round,
              ),
            ),

            const SizedBox(height: 32), // Khoảng cách

            // 2. Dòng chữ thông báo
            const Text(
              'Đang tìm cung đường\nphù hợp với bạn',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
                height: 1.5,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ),
    );
  }
}