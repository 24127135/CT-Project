import 'package:flutter/material.dart';
import 'package:frontend/features/home/widgets/route_card.dart';
import 'package:frontend/features/preference_matching/screen/route_profile_page.dart';
import 'package:frontend/features/preference_matching/models/route_model.dart';
import 'package:frontend/features/preference_matching/models/mock_route.dart'; // Import mock data để backup
import 'package:frontend/utils/app_colors.dart';
import 'package:frontend/utils/app_styles.dart';

class HomeView extends StatelessWidget {
  // 1. Thêm biến để nhận dữ liệu từ màn hình Waiting
  final List<RouteModel>? suggestedRoutes;

  const HomeView({super.key, this.suggestedRoutes});

  @override
  Widget build(BuildContext context) {
    // 2. Logic chọn nguồn dữ liệu: Ưu tiên dữ liệu truyền vào, nếu null thì dùng mock
    final List<RouteModel> displayRoutes = suggestedRoutes ?? mockRoutes;

    // Tiêu đề thay đổi tùy ngữ cảnh
    final String title = suggestedRoutes != null
        ? 'Kết quả phù hợp nhất'
        : 'Gợi ý cho bạn';

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: const Text('Trang chủ', style: AppStyles.appBarTitle),
        backgroundColor: AppColors.lightGray,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: displayRoutes.isEmpty
          ? const Center(child: Text("Không tìm thấy lộ trình phù hợp :("))
          : ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          const SizedBox(height: 16),
          Text(title, style: AppStyles.heading),
          const SizedBox(height: 16),

          // 3. Hiển thị danh sách (Map từ displayRoutes)
          ...displayRoutes.map((route) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: RouteCard(
              route: route,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RouteProfilePage(route: route),
                  ),
                );
              },
            ),
          )),
        ],
      ),
    );
  }
}