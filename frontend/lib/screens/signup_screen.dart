import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../services/auth_service.dart'; // Import Service
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
  final AuthService _authService = AuthService();

  bool _isAgreed = false;
  bool _isLoading = false;

  Future<void> _handleSignup() async {
    if (!_isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the terms')),
      );
      return;
    }

    final email = _emailController.text.trim();
    // name is optional for now — Supabase signUp handles basic profile creation.
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);

    try {
      await _authService.register(email, password);
      if (!mounted) return;
      // After signup, user must confirm via email (magic link). Show OTP screen to instruct.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(email: email),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... UI code is the same, just update the button to handle loading ...
    return Scaffold(
      // ... scaffold setup ...
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ... existing UI fields ...
              const SizedBox(height: 20),
              const Text('Tạo tài khoản Trek Guide', style: AppStyles.heading),
              const SizedBox(height: 32),

              CustomTextField(
                hintText: 'Họ và tên',
                controller: _nameController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hintText: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hintText: 'Mật khẩu',
                controller: _passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 24),

              // Terms Checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _isAgreed,
                      activeColor: AppColors.primaryGreen,
                      onChanged: (val) =>
                          setState(() => _isAgreed = val ?? false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Tôi đồng ý với các Điều khoản và Thỏa thuận của app.',
                      style: TextStyle(color: AppColors.textGray, fontSize: 13),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    )
                  : CustomButton(
                      text: 'Tạo tài khoản',
                      onPressed: _handleSignup,
                    ),

              const SizedBox(height: 40),
              // ... existing footer ...
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Đã có tài khoản? '),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    ),
                    child: const Text('Đăng nhập', style: AppStyles.linkText),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
