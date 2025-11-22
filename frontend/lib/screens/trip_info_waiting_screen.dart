import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Import đúng các file
import '../../providers/trip_provider.dart';
import '../features/preference_matching/models/route_model.dart';
import '../features/preference_matching/screen/preference_matching_page.dart';

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
      // 1. Gọi API (Thêm delay giả lập cho đẹp nếu muốn)
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      final rawData = await context.read<TripProvider>().fetchSuggestedRoutes();

      if (!mounted) return;

      // 2. Parse dữ liệu: JSON -> RouteModel
      final List<RouteModel> routes = rawData.map((item) {
        return RouteModel.fromJson(item);
      }).toList();

      // 3. Chuyển hướng sang PreferenceMatchingPage
      // Lưu ý: Ta truyền list 'routes' sang. Nếu nó rỗng [], trang kia sẽ tự hiện Empty State.
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