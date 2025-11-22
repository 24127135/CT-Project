import 'package:flutter/material.dart';
import 'package:frontend/features/home/widgets/route_card.dart';
import 'package:frontend/features/preference_matching/screen/route_profile_page.dart';
import 'package:frontend/features/preference_matching/models/mock_route.dart';
import 'package:frontend/utils/app_colors.dart';
import 'package:frontend/utils/app_styles.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/widgets/custom_button.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: const Text('Gợi ý cho bạn', style: AppStyles.appBarTitle),
        backgroundColor: AppColors.lightGray,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Add padding to bottom for the button
        children: [
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
      bottomSheet: Container(
        color: AppColors.lightGray,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: CustomButton(
          text: 'Trang chủ',
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
      ),
    );
  }
}
