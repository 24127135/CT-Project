import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_button.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import 'home_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = 
      List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = 
      List.generate(4, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleVerification() {
    String otp = _otpControllers.map((c) => c.text).join();
    // TODO: Connect to Django backend to verify OTP
    print('OTP entered: $otp');
    
    // Navigate to Home Screen and remove previous routes so user can't back to OTP
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Xác thực',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              // Title
              const Text(
                'Xác thực tài khoản',
                style: AppStyles.heading,
              ),
              const SizedBox(height: 8),
              // Subtitle
              const Text(
                'Nhập mã xác thực OTP chúng tôi đã gửi về địa\nchỉ email của bạn',
                style: AppStyles.subheading,
              ),
              const SizedBox(height: 32),
              // OTP input boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 60,
                    height: 60,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.borderGreen,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.borderGreen,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 3) {
                          _focusNodes[index + 1].requestFocus();
                        }
                        if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              // Resend OTP link
              Row(
                children: [
                  const Text(
                    'Chưa nhận được mã? ',
                    style: TextStyle(color: AppColors.textDark),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Implement resend OTP
                    },
                    child: const Text(
                      'Gửi lại',
                      style: AppStyles.linkText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Verify button
              CustomButton(
                text: 'Đăng nhập',
                onPressed: _handleVerification,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
