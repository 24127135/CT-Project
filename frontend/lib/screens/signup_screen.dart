import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import 'otp_verification_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // State for the checkbox
  bool _isAgreed = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    if (!_isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đồng ý với điều khoản sử dụng')),
      );
      return;
    }

    // TODO: Connect to Django backend API for Registration here
    // On success, navigate to OTP verification
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OtpVerificationScreen(),
      ),
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
          'Đăng ký',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Main Heading
              const Text(
                'Tạo tài khoản Trek Guide',
                style: AppStyles.heading,
              ),
              const SizedBox(height: 32),
              
              // Full Name Field
              CustomTextField(
                hintText: 'Họ và tên',
                controller: _nameController,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 16),
              
              // Email Field
              CustomTextField(
                hintText: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              
              // Password Field
              CustomTextField(
                hintText: 'Mật khẩu',
                controller: _passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 24),

              // Checkbox Terms & Conditions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Align to top of text
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _isAgreed,
                      activeColor: AppColors.primaryGreen,
                      side: const BorderSide(color: AppColors.primaryGreen, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (bool? value) {
                        setState(() {
                          _isAgreed = value ?? false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(color: AppColors.textGray, fontSize: 13, height: 1.5),
                        children: [
                          TextSpan(text: 'Tôi đồng ý với các '),
                          TextSpan(
                            text: 'Điều khoản',
                            style: TextStyle(
                              color: Colors.black, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          TextSpan(text: ' và '),
                          TextSpan(
                            text: 'Thỏa thuận',
                            style: TextStyle(
                              color: Colors.black, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          TextSpan(text: ' của app.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              
              // Create Account Button
              CustomButton(
                text: 'Tạo tài khoản',
                onPressed: _handleSignup,
              ),
              
              const SizedBox(height: 40), // Spacing before bottom link

              // Already have account link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Đã có tài khoản? ',
                    style: TextStyle(color: AppColors.textDark),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Pop back to Login Screen
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Đăng nhập',
                      style: AppStyles.linkText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}