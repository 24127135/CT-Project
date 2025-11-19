import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'login_screen.dart';
import 'otp_verification_screen.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Biến quản lý trạng thái checkbox
  bool _isChecked = false;

  // Màu chủ đạo (Lấy từ ảnh)
  final Color primaryGreen = const Color(0xFF56AB2F); // Xanh lá tươi
  final Color backgroundColor = const Color(0xFFF9F8F4); // Màu kem nhạt

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      // AppBar đơn giản với nút Back
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () {
            Navigator.pop(context); // Quay lại màn hình trước
          },
        ),
        centerTitle: true,
        title: const Text(
          "Đăng ký",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // --- TIÊU ĐỀ ---
              const Text(
                "Tạo tài khoản Trek Guide",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 30),

              // --- FORM NHẬP LIỆU ---
              _buildTextField(label: "Họ và tên"),
              const SizedBox(height: 16),
              _buildTextField(label: "Email", inputType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildTextField(label: "Mật khẩu", isPassword: true),

              const SizedBox(height: 20),

              // --- CHECKBOX ĐIỀU KHOẢN ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _isChecked,
                      activeColor: primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: BorderSide(color: primaryGreen, width: 1.5),
                      onChanged: (value) {
                        setState(() {
                          _isChecked = value ?? false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Sử dụng RichText để in đậm một số từ
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: "Tôi đồng tình với các ",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.4),
                        children: [
                          const TextSpan(
                            text: "Điều khoản",
                            style: TextStyle(
                              color: Colors.black, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          TextSpan(
                            text: " và ",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const TextSpan(
                            text: "Thỏa thuận",
                            style: TextStyle(
                              color: Colors.black, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          TextSpan(
                            text: " của Trek Guide.",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // --- NÚT TẠO TÀI KHOẢN ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OtpVerificationScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shadowColor: primaryGreen.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Tạo tài khoản",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 100), // Khoảng trống để đẩy footer xuống dưới nếu cần

              // --- FOOTER: ĐÃ CÓ TÀI KHOẢN ---
              Center(
                child: RichText(
                  text: TextSpan(
                    text: "Đã có tài khoản? ",
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    children: [
                      TextSpan(
                        text: "Đăng nhập",
                        style: TextStyle(
                          color: primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            
                            Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
                          },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget tái sử dụng cho TextField để code gọn hơn
  Widget _buildTextField({
    required String label,
    bool isPassword = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        obscureText: isPassword,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[500]),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          // Viền khi không focus (Màu xanh lá nhạt như ảnh)
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryGreen, width: 1.0),
          ),
          // Viền khi focus (Màu xanh đậm hơn)
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryGreen, width: 2.0),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}