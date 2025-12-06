import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Import đúng các file
import '../providers/trip_provider.dart';
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
      if (!mounted) return;

      // Fetch suggested routes from provider
      final List<RouteModel> routes = await context.read<TripProvider>().fetchSuggestedRoutes();

      if (!mounted) return;

      // Navigate to preference matching page with fetched routes
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PreferenceMatchingPage(routes: routes),
        ),
      );

    } catch (error) {
      if (!mounted) return;
      
      // Show error dialog
      if (!mounted) return;
      try {
        await showDialog<void>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Lỗi'),
            content: Text('Không thể tìm lộ trình: $error'),
            actions: [TextButton(onPressed: () => Navigator.of(c).pop(), child: const Text('Đóng'))],
          ),
        );
      } catch (e) {
        // Silently fail if dialog cannot be shown
      }

      // Navigate to empty-state preference page
      if (!mounted) return;
      try {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const PreferenceMatchingPage(routes: []),
          ),
        );
      } catch (e) {
        // Silently fail if navigation fails
      }
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