import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_button.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../services/auth_service.dart'; // Import Service
import 'home_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email; // Add email field

  const OtpVerificationScreen({
    Key? key, 
    required this.email // Require it in constructor
  }) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = 
      List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = 
      List.generate(4, (index) => FocusNode());
  final AuthService _authService = AuthService();
  bool _isLoading = false;

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

  Future<void> _handleVerification() async {
    String otp = _otpControllers.map((c) => c.text).join();
    
    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the full 4-digit code')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Call Backend
    final result = await _authService.verifyOtp(widget.email, otp);

    setState(() => _isLoading = false);

    if (result != null) {
      // SUCCESS: Token received
      print("Access Token: ${result['access']}");
      // TODO: Save this token using flutter_secure_storage or SharedPreferences
      
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP or verification failed')),
      );
    }
  }

  // ... imports remain the same ...

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
        title: const Text('Xác thực', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SafeArea(
        // WRAP IN SingleChildScrollView
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 60),
                const Text('Xác thực tài khoản', style: AppStyles.heading),
                const SizedBox(height: 8),
                Text(
                  'Nhập mã xác thực OTP chúng tôi đã gửi về:\n${widget.email}',
                  textAlign: TextAlign.center,
                  style: AppStyles.subheading,
                ),
                const SizedBox(height: 32),
                
                // OTP Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(4, (index) {
                    return SizedBox(
                      width: 60, height: 60,
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.borderGreen, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.borderGreen, width: 2),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 3) _focusNodes[index + 1].requestFocus();
                          if (value.isEmpty && index > 0) _focusNodes[index - 1].requestFocus();
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),
                
                // Verify Button
                _isLoading 
                    ? const CircularProgressIndicator(color: AppColors.primaryGreen)
                    : CustomButton(text: 'Xác nhận', onPressed: _handleVerification),
              ],
            ),
          ),
        ),
      ),
    );
  }
}