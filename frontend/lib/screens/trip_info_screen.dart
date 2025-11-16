import 'package:flutter/material.dart';
import 'trip_time_screen.dart'; // Import màn hình Bước 2

class TripInfoScreen extends StatefulWidget {
  const TripInfoScreen({super.key});

  @override
  State<TripInfoScreen> createState() => _TripInfoScreenState();
}

class _TripInfoScreenState extends State<TripInfoScreen> {
  // Biến để lưu trữ lựa chọn của người dùng cho "Loại hình nghỉ ngơi"
  String? _selectedAccommodation;
  // Biến để lưu trữ lựa chọn của người dùng cho "Số người đi cùng"
  String? _selectedPaxGroup;

  // Màu xanh lá chủ đạo (bạn có thể đổi mã màu này nếu cần)
  final Color primaryGreen = const Color(0xFF4CAF50); // Màu xanh lá sáng
  final Color darkGreen = const Color(0xFF388E3C); // Màu xanh lá đậm hơn cho AppBar

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- 1. APPBAR (Thanh trên cùng) ---
      appBar: AppBar(
        // Nút Back (màu trắng)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Đổi màu thành trắng
          onPressed: () {
            // (Sau này chúng ta sẽ xử lý logic quay lại ở đây)
          },
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin chuyến đi',
              style: TextStyle(
                color: Colors.white, // Đổi màu chữ thành trắng
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Bước 1/5',
              style: TextStyle(
                color: Colors.white70, // Đổi màu chữ thành trắng mờ
                fontSize: 14,
              ),
            ),
          ],
        ),
        backgroundColor: darkGreen, // Đặt màu nền AppBar là xanh lá đậm
        elevation: 0, // Bỏ đổ bóng
      ),

      // --- 2. BODY (Nội dung chính) ---
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề "Địa điểm trekking"
              const Text(
                'Địa điểm trekking',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // Ô tìm kiếm
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search, color: Colors.black54),
                  suffixIcon: const Icon(Icons.mic, color: Colors.black54), // Thêm biểu tượng mic
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide.none, // Bỏ viền
                  ),
                  filled: true, // Bật màu nền
                  fillColor: Colors.grey.shade200, // Màu nền của ô search
                ),
              ),

              const SizedBox(height: 24), // Khoảng cách

              // Tiêu đề "Loại hình nghỉ ngơi"
              const Text(
                'Loại hình nghỉ ngơi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // --- Các nút lựa chọn cho Loại hình nghỉ ngơi ---
              _buildChoiceButton(
                label: 'Cắm trại',
                isSelected: _selectedAccommodation == 'Cắm trại',
                onTap: () {
                  setState(() {
                    _selectedAccommodation = 'Cắm trại';
                  });
                },
              ),
              const SizedBox(height: 12),
              _buildChoiceButton(
                label: 'Homestay',
                isSelected: _selectedAccommodation == 'Homestay',
                onTap: () {
                  setState(() {
                    _selectedAccommodation = 'Homestay';
                  });
                },
              ),
              const SizedBox(height: 12),
              _buildChoiceButton(
                label: 'Kết hợp',
                isSelected: _selectedAccommodation == 'Kết hợp',
                onTap: () {
                  setState(() {
                    _selectedAccommodation = 'Kết hợp';
                  });
                },
              ),

              const SizedBox(height: 24), // Khoảng cách

              // Tiêu đề "Số người đi cùng"
              const Text(
                'Số người đi cùng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // --- Các nút lựa chọn cho Số người đi cùng ---
              _buildChoiceButton(
                label: 'Đơn lẻ (1-2 người)',
                isSelected: _selectedPaxGroup == 'Đơn lẻ (1-2 người)',
                onTap: () {
                  setState(() {
                    _selectedPaxGroup = 'Đơn lẻ (1-2 người)';
                  });
                },
              ),
              const SizedBox(height: 12),
              _buildChoiceButton(
                label: 'Nhóm nhỏ (3-6 người)',
                isSelected: _selectedPaxGroup == 'Nhóm nhỏ (3-6 người)',
                onTap: () {
                  setState(() {
                    _selectedPaxGroup = 'Nhóm nhỏ (3-6 người)';
                  });
                },
              ),
              const SizedBox(height: 12),
              _buildChoiceButton(
                label: 'Nhóm đông (7+ người)',
                isSelected: _selectedPaxGroup == 'Nhóm đông (7+ người)',
                onTap: () {
                  setState(() {
                    _selectedPaxGroup = 'Nhóm đông (7+ người)';
                  });
                },
              ),
            ],
          ),
        ),
      ),

      // --- NÚT "TIẾP THEO" Ở DƯỚI CÙNG ---
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // Điều hướng đến Bước 2
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TripTimeScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen, // Màu xanh lá sáng
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Tiếp theo',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // Widget trợ giúp (helper) để xây dựng các nút lựa chọn
  Widget _buildChoiceButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        width: double.infinity, // Nút rộng hết cỡ
        decoration: BoxDecoration(
          color: isSelected ? primaryGreen : Colors.white, // Đổi màu khi được chọn
          border: Border.all(
            color: isSelected ? primaryGreen : Colors.grey.shade300,
            width: isSelected ? 2 : 1, // Viền đậm hơn khi chọn
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        // Văn bản được căn lề trái
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0), // Căn lề trái 16.0
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}