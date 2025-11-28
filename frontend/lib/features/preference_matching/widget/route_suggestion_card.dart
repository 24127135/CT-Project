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
            // Không dùng alignment: Alignment.bottomLeft nữa để cho phép nội dung tự giãn
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

              // 2. Gradient Overlay (Dùng Positioned.fill để lấp đầy)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.9), // Đen đậm ở đáy
                        Colors.black.withValues(alpha: 0.6), // Đen vừa ở giữa
                        Colors.transparent,                  // Trong suốt ở trên
                      ],
                      stops: const [0.0, 0.6, 1.0], // Kéo dài vùng đen lên cao hơn
                    ),
                  ),
                ),
              ),

              // 3. Nội dung Text (Đặt trong Container ở đáy để tự đẩy chiều cao card)
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  padding: const EdgeInsets.all(16.0), // Padding xung quanh text
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

                      // AI Note hoặc Mô tả thường
                      route.aiNote.isNotEmpty
                          ? Container(
                        padding: const EdgeInsets.all(12), // Tăng padding bên trong box AI
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF66BB6A),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                                Icons.auto_awesome,
                                color: Color(0xFF66BB6A),
                                size: 18 // Tăng nhẹ kích thước icon
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                route.aiNote,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14, // Tăng nhẹ cỡ chữ
                                  fontStyle: FontStyle.italic,
                                  height: 1.4, // Tăng khoảng cách dòng cho dễ đọc
                                ),
                                // Bỏ maxLines và overflow để hiển thị hết nội dung
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
                        maxLines: 3, // Tăng số dòng tối đa cho mô tả thường
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