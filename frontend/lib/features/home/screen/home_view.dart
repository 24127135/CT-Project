import 'package:flutter/material.dart';
import 'package:frontend/features/home/widgets/route_card.dart';
import 'package:frontend/features/preference_matching/screen/route_profile_page.dart';
import 'package:frontend/features/preference_matching/models/mock_route.dart';
import 'package:frontend/utils/app_colors.dart';
import 'package:frontend/utils/app_styles.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: const Text('Trang chủ', style: AppStyles.appBarTitle),
        backgroundColor: AppColors.lightGray,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          const SizedBox(height: 16),
          const Text('Gợi ý cho bạn', style: AppStyles.heading),
          const SizedBox(height: 16),
          ...mockRoutes.map((route) => Padding(
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
