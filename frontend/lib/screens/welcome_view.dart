import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'login_screen.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Sử dụng Stack hoặc Container để làm nền Gradient
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE0F2F1), // Màu trắng xanh nhạt ở góc trên
              Color(0xFFA5D6A7), // Màu xanh lá nhạt ở giữa
              Color(0xFF66BB6A), // Màu xanh lá đậm hơn ở dưới
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                
                // --- LOGO ---
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/icon/app_icon.png', 
                      width: 160,
                      height: 160,
                      fit: BoxFit.cover,
                      // Placeholder khi chưa có ảnh thật
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 160, 
                          height: 160, 
                          color: Colors.white,
                          child: const Icon(Icons.terrain, size: 80, color: Color(0xFF2E7D32)),
                        );
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // --- TÊN ỨNG DỤNG ---
                const Text(
                  "TREK GUIDE",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900, // Font đậm
                    color: Color(0xFF1B5E20), // Màu xanh đen đậm
                    letterSpacing: 1.2,
                  ),
                ),
                
                const Spacer(flex: 2),

                // --- SLOGAN ---
                const Text(
                  "Hành trình vạn dặm bắt đầu từ một bước cùng Trek Guide khám phá thiên nhiên Việt Nam.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5, // Khoảng cách dòng
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                const SizedBox(height: 30),

                // --- NÚT 1: BẮT ĐẦU KHÁM PHÁ ---
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF56AB2F), // Màu xanh lá tươi
                      foregroundColor: Colors.white, // Màu chữ
                      elevation: 4,
                      shadowColor: Colors.greenAccent.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Bắt đầu khám phá!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // --- NÚT 2: ĐÃ CÓ TÀI KHOẢN? ---
                // Nút này có hiệu ứng trong suốt (glassmorphism) nhẹ
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.25), // Nền trắng mờ
                      foregroundColor: Colors.white, // Màu chữ
                      side: const BorderSide(color: Colors.white, width: 1.5), // Viền trắng
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Đã có tài khoản?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}