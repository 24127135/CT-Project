import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Import đúng các file
import '../../providers/trip_provider.dart';
import '../features/preference_matching/models/route_model.dart';
import '../features/home/screen/home_view.dart'; // <--- Import HomeView

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
      // (Đảm bảo bạn đã thêm factory RouteModel.fromJson ở bước trước nhé!)
      final List<RouteModel> routes = rawData.map((item) {
        return RouteModel.fromJson(item);
      }).toList();

      // 3. Chuyển hướng sang HomeView và TRUYỀN DỮ LIỆU
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => HomeView(suggestedRoutes: routes), // <--- Truyền routes vào đây
        ),
            (Route<dynamic> route) => false, // Xóa hết các màn hình cũ trong stack
      );

    } catch (error) {
      if (!mounted) return;
      // Xử lý lỗi
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Có lỗi xảy ra'),
          content: Text('Không thể tải dữ liệu: $error'),
          actions: [
            TextButton(
              child: const Text('Về trang chủ'),
              onPressed: () {
                // Nếu lỗi thì về HomeView mặc định (không truyền data -> hiện mock)
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomeView()),
                      (route) => false,
                );
              },
            )
          ],
        ),
      );
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