import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../services/auth_service.dart'; // Import Service
import '../features/home/screen/home_view.dart';
import 'otp_verification_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Call Backend
    final success = await _authService.login(email, password);

    setState(() => _isLoading = false);

    if (success) {
      if (!mounted) return;
      // Navigate to OTP screen passing the email
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(email: email),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Check credentials.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (UI code remains mostly the same, just updating button state) ...
    return Scaffold(
      // ... existing scaffold code ...
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ... existing UI headers ...
              const SizedBox(height: 60),
              const Text('Chúc một ngày tốt lành!', style: AppStyles.heading),
              const SizedBox(height: 32),
              
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
              
              // Loading Indicator or Button
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                  : CustomButton(text: 'Đăng nhập', onPressed: _handleLogin),
              
              const Spacer(),
              
              // ... existing footer ...
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Chưa có tài khoản? ', style: TextStyle(color: AppColors.textDark)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignupScreen()),
                      );
                    },
                    child: const Text('Đăng ký', style: AppStyles.linkText),
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