import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_button.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../services/auth_service.dart'; // Import Service

class OtpVerificationScreen extends StatefulWidget {
  final String email; 

  const OtpVerificationScreen({
    Key? key, 
    required this.email
  }) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final AuthService _authService = AuthService();
  final TokenService _tokenService = TokenService(); // 2. Initialize TokenService
  
  bool _isLoading = false;
  // Accept 4-digit OTP (preferred)
  static const int _otpLength = 4;
  final List<TextEditingController> _controllers = List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(_otpLength, (_) => FocusNode());
  // Flexible full-code controller (accepts paste or typing of full code 4-8 digits)
  final TextEditingController _fullOtpController = TextEditingController();
  // Control whether to show the single-digit boxes. Hidden by default for now.
  final bool _showDigitBoxes = false;
  // Focus node for the full-code input when digit boxes are hidden
  final FocusNode _fullOtpFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Autofocus first field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (_showDigitBoxes) {
          _focusNodes[0].requestFocus();
        } else {
          _fullOtpFocus.requestFocus();
        }
        // Send OTP automatically when the screen appears
        _handleVerification();
      }
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _fullOtpFocus.dispose();
    _fullOtpController.dispose();
    super.dispose();
  }

  Future<void> _handleVerification() async {
    setState(() => _isLoading = true);
    try {
      // Send an email OTP (code)
      await _authService.sendEmailOtp(widget.email);
      if (!mounted) return;
      // Clear any previous digits and focus first input
      for (final c in _controllers) {
        c.clear();
      }
      if (_showDigitBoxes) {
        _focusNodes[0].requestFocus();
      } else {
        _fullOtpFocus.requestFocus();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent — check your email')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send OTP: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyCode() async {
    // Prefer the full OTP field if the user pasted/typed the entire code
    final full = _fullOtpController.text.trim();
    String code;
    if (full.isNotEmpty && full.length >= 4 && full.length <= 8) {
      code = full;
    } else {
      code = _controllers.map((c) => c.text.trim()).join();
    }
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter the code')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _authService.verifyEmailOtp(widget.email, code);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verified — signing in')));
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to verify OTP: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
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
        title: const Text('Xác thực', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SafeArea(
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
                
                const SizedBox(height: 24),
                Text(
                  'We will send an OTP code to the email below. Enter the code here to complete sign-in.',
                  textAlign: TextAlign.center,
                  style: AppStyles.bodyText,
                ),
                const SizedBox(height: 16),
                Text(widget.email, style: AppStyles.subheading, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator(color: AppColors.primaryGreen)
                    : Column(
                        children: [
                          // Digit boxes are hidden by default; toggle `_showDigitBoxes` to show them.
                          _showDigitBoxes
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(_otpLength, (i) {
                                    return Container(
                                      width: 54,
                                      margin: const EdgeInsets.symmetric(horizontal: 6),
                                      child: TextField(
                                        controller: _controllers[i],
                                        focusNode: _focusNodes[i],
                                        autofocus: i == 0,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(1)],
                                        onChanged: (v) {
                                          // Delay the focus change slightly to avoid
                                          // interfering with the current input event and
                                          // platform keyboard behavior which can cause
                                          // unexpected unfocus on some devices/emulators.
                                          if (v.isNotEmpty) {
                                            if (i < _otpLength - 1) {
                                              Future.delayed(const Duration(milliseconds: 120), () {
                                                if (!mounted) return;
                                                _focusNodes[i + 1].requestFocus();
                                              });
                                            } else {
                                              // Last digit entered — keep focus on the last
                                              // box to avoid the keyboard dismissing.
                                            }
                                          } else {
                                            if (i > 0) {
                                              Future.delayed(const Duration(milliseconds: 80), () {
                                                if (!mounted) return;
                                                _focusNodes[i - 1].requestFocus();
                                              });
                                            }
                                          }
                                        },
                                        decoration: const InputDecoration(border: OutlineInputBorder()),
                                      ),
                                    );
                                  }),
                                )
                              : const SizedBox.shrink(),
                            const SizedBox(height: 12),
                            // Flexible full-code input (accept pasted codes from Supabase)
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 24),
                              child: TextField(
                                controller: _fullOtpController,
                                focusNode: _fullOtpFocus,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8)],
                                decoration: const InputDecoration(
                                  labelText: 'Or paste full code here',
                                  border: OutlineInputBorder(),
                                  hintText: 'Paste the code you received',
                                ),
                                onChanged: (v) {
                                  final trimmed = v.trim();
                                  if (trimmed.length >= 4 && trimmed.length <= 8) {
                                    if (_showDigitBoxes) {
                                      // Auto-fill single-digit boxes for UX feedback
                                      for (var i = 0; i < _otpLength; i++) {
                                        _controllers[i].text = i < trimmed.length ? trimmed[i] : '';
                                      }
                                    }
                                    // Unfocus keyboard after paste
                                    FocusScope.of(context).unfocus();
                                  }
                                },
                              ),
                            ),
                          const SizedBox(height: 12),
                          CustomButton(text: 'Verify code', onPressed: _verifyCode),
                          const SizedBox(height: 12),
                          CustomButton(text: 'Send OTP', onPressed: _handleVerification),
                          TextButton(
                            onPressed: _isLoading ? null : _handleVerification,
                            child: const Text('Resend OTP'),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}