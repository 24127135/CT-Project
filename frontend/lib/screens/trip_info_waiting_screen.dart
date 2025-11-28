import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Import đúng các file
import '../../providers/trip_provider.dart';
import '../features/preference_matching/models/route_model.dart';
import '../features/preference_matching/screen/preference_matching_page.dart';
import '../services/gemini_service.dart';

class WaitingScreen extends StatefulWidget {
  const WaitingScreen({super.key});

  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      //await GeminiService().checkAvailableModels();
      if (!mounted) return;

      // 1. Gọi Provider (Hàm này giờ đã trả về List<RouteModel> rồi, không cần parse nữa)
      final List<RouteModel> routes = await context.read<TripProvider>().fetchSuggestedRoutes();

      if (!mounted) return;

      // 2. Chuyển hướng ngay
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PreferenceMatchingPage(routes: routes),
        ),
      );

    } catch (error) {
      if (!mounted) return;
      // 4. Xử lý lỗi (Ví dụ mất mạng, server sập)
      // Lúc này vẫn có thể chuyển sang PreferenceMatchingPage với list rỗng để hiện thông báo
      // Hoặc hiện Dialog báo lỗi cụ thể. Ở đây mình chọn hiện trang Empty State cho đồng bộ.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const PreferenceMatchingPage(routes: []),
        ),
      );

      // Hoặc nếu muốn debug thì uncomment dòng dưới để xem lỗi
      // print("Lỗi fetch data: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                strokeWidth: 8,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                backgroundColor: Colors.grey.shade300,
                strokeCap: StrokeCap.round,
              ),
            ),
            const SizedBox(height: 32),
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