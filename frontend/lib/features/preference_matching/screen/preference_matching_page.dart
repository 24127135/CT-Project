import 'package:flutter/material.dart';
import 'package:frontend/features/preference_matching/models/route_model.dart';
import 'package:frontend/features/preference_matching/widget/route_suggestion_card.dart';
import 'package:frontend/features/preference_matching/screen/route_profile_page.dart';
import 'package:frontend/utils/app_colors.dart';
import 'package:frontend/utils/app_styles.dart';
import 'package:frontend/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import '../../../screens/home_screen.dart';
import '../../../providers/trip_provider.dart';

class PreferenceMatchingPage extends StatelessWidget {
  final List<RouteModel>? routes;

  const PreferenceMatchingPage({super.key, this.routes});

  @override
  Widget build(BuildContext context) {
    final routeList = routes ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4), // Light gray background
      appBar: AppBar(
        title: const Text('Cung đường phù hợp', style: AppStyles.appBarTitle),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: AppColors.textDark,
        shadowColor: Colors.black.withValues(alpha: 0.1),
      ),
      body: routeList.isEmpty
          ? _buildEmptyState(context)
          : _buildRouteList(context, routeList),
    );
  }

  Widget _buildRouteList(BuildContext context, List<RouteModel> routeList) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: routeList.length,
      itemBuilder: (context, index) {
        final route = routeList[index];
        return RouteSuggestionCard(
          route: route,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RouteProfilePage(route: route),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/empty_state.png', height: 150),
            const SizedBox(height: 24),
            Text(
              'Không có cung đường nào\nphù hợp với nhu cầu của bạn!',
              textAlign: TextAlign.center,
              style: AppStyles.heading.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'VỀ TRANG CHỦ',
              onPressed: () async {
                // Capture navigator and provider synchronously to avoid using `context` after async gaps
                final navigator = Navigator.of(context);
                final tripProvider = Provider.of<TripProvider>(context, listen: false);

                final shouldCancel = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Quay về trang chủ'),
                    content: const Text('Bạn có muốn hủy kế hoạch hiện tại và trở về trang chủ?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Không')),
                      TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Có', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );

                if (shouldCancel != true) return;

                try {
                  await tripProvider.cancelDraftPlan();
                } catch (_) {
                  // ignore errors but log
                }

                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomePage()),
                  (route) => false,
                );
              },
              backgroundColor: AppColors.primaryGreen,
            ),
          ],
        ),
      ),
    );
  }
}
