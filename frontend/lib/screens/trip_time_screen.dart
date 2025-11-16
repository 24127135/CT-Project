import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import thư viện intl

class TripTimeScreen extends StatefulWidget {
  const TripTimeScreen({super.key});

  @override
  State<TripTimeScreen> createState() => _TripTimeScreenState();
}

class _TripTimeScreenState extends State<TripTimeScreen> {
  // Biến để lưu ngày người dùng chọn
  DateTime? _selectedDate;

  // Màu xanh lá
  final Color primaryGreen = const Color(0xFF4CAF50);
  final Color darkGreen = const Color(0xFF388E3C);

  // Hàm để hiển thị lịch
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(), // Ngày bắt đầu
      firstDate: DateTime.now(), // Không cho chọn ngày trong quá khứ
      lastDate: DateTime(2101), // Giới hạn đến năm 2101
      // Tùy chỉnh màu sắc cho lịch
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryGreen, // Màu của ngày được chọn
              onPrimary: Colors.white, // Màu chữ trên ngày được chọn
              onSurface: Colors.black87, // Màu chữ của các ngày khác
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: darkGreen, // Màu chữ của nút OK/Cancel
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    // Nếu người dùng chọn một ngày, cập nhật lại state
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Định dạng ngày tháng, ví dụ: "17/08/2025"
    final String formattedDate = _selectedDate == null
        ? 'MM/DD/YYYY'
        : DateFormat('dd/MM/yyyy').format(_selectedDate!);

    return Scaffold(
      // --- 1. APPBAR (Giống hệt Bước 1) ---
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Quay lại Bước 1
            Navigator.pop(context);
          },
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin chuyến đi',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Bước 2/5', // <-- THAY ĐỔI
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
        backgroundColor: darkGreen,
        elevation: 0,
      ),

      // --- 2. BODY (Nội dung chính) ---
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thời gian chuyến đi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // --- 3. Ô CHỌN NGÀY (Textfield "giả") ---
              GestureDetector(
                onTap: () {
                  _selectDate(context); // Gọi hàm hiển thị lịch khi nhấn
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Icon và Ngày tháng
                      Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey.shade600),
                          const SizedBox(width: 12),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 16,
                              color: _selectedDate == null
                                  ? Colors.grey.shade600
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      // Icon Lịch
                      Icon(Icons.calendar_month, color: primaryGreen),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              // Dòng chữ "Hãy chọn đủ các thông tin bắt buộc"
              if (_selectedDate == null) // Chỉ hiển thị nếu chưa chọn ngày
                Text(
                  '❗️ Hãy chọn đủ các thông tin bắt buộc',
                  style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                ),
            ],
          ),
        ),
      ),

      // --- 4. CÁC NÚT BẤM (Dưới cùng) ---
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Nút Back
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 28),
              onPressed: () {
                Navigator.pop(context); // Quay lại Bước 1
              },
            ),
            // Nút Tiếp theo (Mở rộng)
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // (Sau này sẽ điều hướng đến Bước 3/5)
                  print('Ngày đã chọn: $_selectedDate');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
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
          ],
        ),
      ),
    );
  }
}