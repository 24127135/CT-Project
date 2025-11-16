import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 14,
    color: AppColors.textGray,
  );

  static const TextStyle linkText = TextStyle(
    fontSize: 14,
    color: AppColors.primaryGreen,
    fontWeight: FontWeight.w600,
  );
}
