import 'package:flutter/material.dart';
import 'package:frontend/features/preference_matching/models/route_model.dart';
import 'package:frontend/utils/app_colors.dart';
import 'package:frontend/utils/app_styles.dart';

class RouteSuggestionCard extends StatelessWidget {
  final RouteModel route;
  final VoidCallback onTap;

  const RouteSuggestionCard({
    super.key,
    required this.route,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        // Đặt chiều cao tối thiểu để card không quá nhỏ khi ít chữ
        constraints: const BoxConstraints(minHeight: 220),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          // Thêm màu nền phòng khi ảnh chưa tải xong
          color: AppColors.lightGray,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Stack(
            children: [
              // 1. Ảnh nền (Dùng Positioned.fill để lấp đầy)
              Positioned.fill(
                child: Image.network(
                  route.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 40,
                        color: AppColors.textGray,
                      ),
                    );
                  },
                ),
              ),

              // 2. Lớp phủ Gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.9),
                        Colors.black.withValues(alpha: 0.6),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ),

              // 3. Nội dung Text (Dùng Align để giữ nội dung ở đáy và tự đẩy chiều cao card)
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tên cung đường
                      Text(
                        '${route.name} - ${route.location}',
                        style: AppStyles.suggestionTitle.copyWith(
                          color: Colors.white,
                          shadows: [
                            const Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // --- LOGIC HIỂN THỊ AI NOTE HOẶC MÔ TẢ THƯỜNG ---
                      route.matchReason.isNotEmpty
                          ? Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF66BB6A), // Viền xanh lá
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                                Icons.auto_awesome,
                                color: Color(0xFF66BB6A),
                                size: 18
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                route.matchReason,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  height: 1.4,
                                ),
                                // Đã bỏ maxLines để hiển thị hết nội dung AI
                              ),
                            ),
                          ],
                        ),
                      )
                          : Text(
                        route.description,
                        style: AppStyles.suggestionBody.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.3
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}