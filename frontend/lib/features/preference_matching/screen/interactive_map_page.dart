import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/preference_matching/models/route_model.dart';
import 'package:frontend/utils/app_colors.dart';
import 'package:frontend/utils/app_styles.dart';
import 'package:frontend/widgets/custom_button.dart';
import 'package:frontend/providers/trip_provider.dart';
import 'package:frontend/screens/PEC.dart';

class InteractiveMapPage extends StatefulWidget {
  final RouteModel route;

  const InteractiveMapPage({super.key, required this.route});

  @override
  State<InteractiveMapPage> createState() => _InteractiveMapPageState();
}

class _InteractiveMapPageState extends State<InteractiveMapPage> {
  bool _isLoading = false;

  Future<void> _confirmRoute(BuildContext context) async {
    setState(() => _isLoading = true);
    
    print("🔴 [InteractiveMapPage] Confirm button pressed for Route ID: ${widget.route.id}");

    try {
      // 1. Get Provider
      final tripProvider = Provider.of<TripProvider>(context, listen: false);

      // 2. Call the UPDATE method (Step 6 logic)
      // This avoids creating a new duplicate plan and fixes the 400 error
      await tripProvider.confirmRouteForPlan(widget.route.id);
      
      print("🔴 [InteractiveMapPage] Plan updated successfully.");

      if (!mounted) return;

      // 3. Navigate to PEC Screen
      // Use push so user can go back if needed, or pushReplacement if this is a one-way flow
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PECScreen()),
      );
      
    } catch (e) {
      print("🔴 [InteractiveMapPage] ERROR: $e");
      if (!mounted) return;
      
      String errorMessage = 'Lỗi kết nối server.';
      if (e.toString().contains('Không tìm thấy ID')) {
        errorMessage = 'Lỗi quy trình: Không tìm thấy bản nháp chuyến đi.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map Background
          Container(
            color: AppColors.lightGray,
            child: Image.network(
              widget.route.imageUrl.isNotEmpty 
                  ? widget.route.imageUrl 
                  : 'https://images.unsplash.com/photo-1585435465945-597426701a4d?q=80&w=1974&auto=format&fit=crop',
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => 
                  const Center(child: Icon(Icons.map_outlined, color: AppColors.textGray, size: 60)),
            ),
          ),

          // Top buttons
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildGlassButton(icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
                _buildGlassButton(icon: Icons.threed_rotation, text: '3D', onTap: () {}),
              ],
            ),
          ),

          // Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.45,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                decoration: const BoxDecoration(
                  color: AppColors.sheetBackground,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -4))],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Stats
                      Text('${widget.route.name} - ${widget.route.location}', style: AppStyles.mapTitle),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.route.distanceKm} km, ${widget.route.elevationGainM} m gain, Est. ${widget.route.durationDays} days',
                        style: AppStyles.mapStats,
                      ),
                      const SizedBox(height: 24),

                      // Elevation Graph Placeholder
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(child: Text('Elevation Graph Placeholder', style: TextStyle(color: Colors.grey))),
                      ),
                      const SizedBox(height: 24),

                      // AI Note
                      const Text('AI Note:', style: AppStyles.aiNoteTitle),
                      const SizedBox(height: 8),
                      Text(
                        widget.route.aiNote.isNotEmpty 
                          ? widget.route.aiNote 
                          : 'Thông tin địa hình và thời tiết đang được cập nhật...',
                        style: AppStyles.bodyText,
                      ),
                      const SizedBox(height: 32),

                      // Confirm Button
                      _isLoading 
                        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                        : CustomButton(
                            text: 'XÁC NHẬN LỘ TRÌNH',
                            onPressed: () => _confirmRoute(context),
                            backgroundColor: AppColors.primaryGreen,
                            style: AppStyles.profileButton.copyWith(color: Colors.white),
                          ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton({required IconData icon, String? text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            if (text != null) ...[
              const SizedBox(width: 8),
              Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ]
          ],
        ),
      ),
    );
  }
}