import 'package:flutter/material.dart';
import 'package:frontend/utils/app_colors.dart';
import 'package:frontend/utils/app_styles.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: AppStyles.bodyText, // Use bodyText style for input
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppStyles.hintText, // Use hintText style
        filled: true,
        fillColor: AppColors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.borderGreen,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.primaryGreen,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
