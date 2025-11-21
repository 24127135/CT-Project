import 'package:flutter/material.dart';
import 'package:frontend/features/preference_matching/models/route_model.dart';
import 'package:frontend/utils/app_colors.dart';
import 'package:frontend/utils/app_styles.dart';
import 'package:frontend/widgets/custom_button.dart';

class InteractiveMapPage extends StatelessWidget {
  final RouteModel route;

  const InteractiveMapPage({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map Background (Replaced missing asset with a network image)
          Container(
            color: AppColors.lightGray, // A neutral background for the map area
            child: Image.network(
              'https://images.unsplash.com/photo-1585435465945-597426701a4d?q=80&w=1974&auto=format&fit=crop',
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              // Add a loading builder for a better user experience
              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.map_outlined, color: AppColors.textGray, size: 60)),
            ),
          ),

          // Top buttons (Back, 3D)
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
                      Text('${route.name} - ${route.location}', style: AppStyles.mapTitle),
                      const SizedBox(height: 8),
                      Text(
                        '${route.distanceKm} km, ${route.elevationGainM} m gain, Est. ${route.durationDays} days',
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
                      const Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque euismod, urna eu tincidunt consectetur, nisi nisl aliquet nunc, eget aliquam nisl nunc eget nisl.',
                        style: AppStyles.bodyText,
                      ),
                      const SizedBox(height: 32),

                      // Confirm Button
                      CustomButton(
                        text: 'XÁC NHẬN LỘ TRÌNH',
                        onPressed: () {},
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
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
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
