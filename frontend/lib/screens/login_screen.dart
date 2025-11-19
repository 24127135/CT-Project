import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../features/home/screen/home_view.dart';
import 'otp_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    // TODO: Connect to Django backend API here
    // For now, navigate to Home screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeView(),
      ),
    );
  }

  void _navigateToOTP() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OtpVerificationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions and safe area padding
    final screenHeight = MediaQuery.of(context).size.height;
    final safeArea = MediaQuery.of(context).padding;
    final appBarHeight = AppBar().preferredSize.height;
    
    // Calculate the available height for the body
    final bodyHeight = screenHeight - appBarHeight - safeArea.top - safeArea.bottom;

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.lightGray,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Đăng nhập',
          style: AppStyles.appBarTitle,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: bodyHeight, // Constrain the height
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Chúc một ngày tốt lành!',
                  style: AppStyles.heading,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Đăng nhập để tiếp tục nhé',
                  style: AppStyles.subheading,
                ),
                const SizedBox(height: 40),
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
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _navigateToOTP,
                    child: const Text(
                      'Quên mật khẩu?',
                      style: AppStyles.linkText,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Đăng nhập',
                  onPressed: _handleLogin,
                ),
                const Spacer(), // Pushes the footer content to the bottom
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppStyles.bodyText,
                    children: <TextSpan>[
                      const TextSpan(text: 'Chưa có tài khoản? '),
                      TextSpan(
                        text: 'Đăng ký',
                        style: AppStyles.linkText,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // TODO: Navigate to sign up screen
                          },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
