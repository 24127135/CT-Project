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

  static const TextStyle appBarTitle = TextStyle(
    color: AppColors.textDark,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyText = TextStyle(
    color: AppColors.textDark,
    fontSize: 14,
    height: 1.5, // Added for better readability
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 14,
    color: AppColors.textGray,
  );

  static const TextStyle cardBody = TextStyle(
    fontSize: 12,
    color: AppColors.textGray,
  );

  static const TextStyle suggestionTitle = TextStyle(
    color: AppColors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    shadows: [
      Shadow(color: Colors.black38, offset: Offset(0, 1), blurRadius: 2),
    ],
  );

  static const TextStyle suggestionBody = TextStyle(
    color: Color(0xFFE0E0E0),
    fontSize: 13,
    height: 1.4,
    shadows: [
      Shadow(color: Colors.black38, offset: Offset(0, 1), blurRadius: 2),
    ],
  );

  static const TextStyle profileTitle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
    height: 1.2,
  );

  static const TextStyle profileSubtitle = TextStyle(
    fontSize: 18,
    color: AppColors.white70,
  );

  static const TextStyle statValue = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static const TextStyle statUnit = TextStyle(
    fontSize: 16,
    color: AppColors.white,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle statLabel = TextStyle(
    fontSize: 13,
    color: AppColors.white,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  static const TextStyle profileButton = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    letterSpacing: 0.5,
  );

  static const TextStyle hintText = TextStyle(
    color: AppColors.textHint,
    fontSize: 14,
  );

  static const TextStyle mapTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const TextStyle mapStats = TextStyle(
    fontSize: 14,
    color: AppColors.textGray,
  );

  static const TextStyle aiNoteTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );
}
