import 'package:flutter/material.dart';
import 'package:frontend/features/preference_matching/models/route_model.dart';
import 'package:frontend/utils/app_colors.dart';
import 'package:frontend/utils/app_styles.dart';

class RouteCard extends StatelessWidget {
  final RouteModel route;
  final VoidCallback? onTap;

  const RouteCard({super.key, required this.route, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                route.imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    color: AppColors.lightGray,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      size: 50,
                      color: AppColors.textGray,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(route.name, style: AppStyles.cardTitle),
                  const SizedBox(height: 4),
                  Text(route.location, style: AppStyles.cardSubtitle),
                  const SizedBox(height: 8),
                  Text(
                    route.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.cardBody,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
