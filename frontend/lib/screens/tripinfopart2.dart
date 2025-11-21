import 'package:calendar_date_picker2/calendar_date_picker2.dart'; // Thư viện lịch mới
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/trip_provider.dart';
import 'tripinfopart3.dart';

class TripTimeScreen extends StatefulWidget {
  const TripTimeScreen({super.key});

  @override
  State<TripTimeScreen> createState() => _TripTimeScreenState();
}

class _TripTimeScreenState extends State<TripTimeScreen> {
  final Color primaryGreen = const Color(0xFF4CAF50);
  final Color darkGreen = const Color(0xFF388E3C);

  // --- HÀM HIỂN THỊ LỊCH MỚI (Dùng calendar_date_picker2) ---
  Future<void> _selectDateRange(BuildContext context, TripProvider tripData) async {
    // Cấu hình giao diện lịch
    final config = CalendarDatePicker2WithActionButtonsConfig(
      calendarType: CalendarDatePicker2Type.range, // Chế độ chọn khoảng ngày
      selectedDayHighlightColor: primaryGreen, // Màu ngày được chọn

      // Các icon mũi tên chuyển tháng
      lastMonthIcon: const Icon(Icons.arrow_back_ios, size: 16, color: Colors.black87),
      nextMonthIcon: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black87),

      // Tùy chỉnh text tiêu đề (Tháng/Năm)
      controlsTextStyle: const TextStyle(
        color: Colors.black87,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),

      // Style cho ngày thường
      dayTextStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),

      // Style cho ngày chủ nhật/thứ 7
      weekdayLabelTextStyle: const TextStyle(
        color: Colors.black54,
        fontWeight: FontWeight.bold,
      ),

      // Text nút bấm
      okButtonTextStyle: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
      cancelButtonTextStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
    );

    // Hiển thị Dialog
    final List<DateTime?>? results = await showCalendarDatePicker2Dialog(
      context: context,
      config: config,
      dialogSize: const Size(375, 400), // Kích thước popup gọn gàng
      borderRadius: BorderRadius.circular(15),

      // Nếu đã chọn trước đó, hiển thị lại
      value: (tripData.startDate != null && tripData.endDate != null)
          ? [tripData.startDate, tripData.endDate]
          : [],
    );

    // Xử lý kết quả trả về
    // Thư viện trả về List, ta cần đảm bảo có đủ 2 ngày (Start & End)
    if (results != null && results.length == 2 && results[0] != null && results[1] != null) {
      // Thư viện đã trả về ngày theo thứ tự (start, end), không cần sort lại
      final start = results[0]!;
      final end = results[1]!;

      context.read<TripProvider>().setTripDates(start, end);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe dữ liệu từ Provider
    final tripData = context.watch<TripProvider>();

    // Xử lý hiển thị text ngày tháng
    String dateText = 'MM/DD/YYYY';
    bool hasDate = tripData.startDate != null && tripData.endDate != null;

    if (hasDate) {
      String start = DateFormat('dd/MM/yyyy').format(tripData.startDate!);
      String end = DateFormat('dd/MM/yyyy').format(tripData.endDate!);
      dateText = '$start - $end';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Màu nền xám nhẹ
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Thông tin chuyến đi',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
            ),
            Text(
                'Bước 2/5',
                style: TextStyle(color: Colors.white70, fontSize: 14)
            ),
          ],
        ),
        backgroundColor: primaryGreen,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Thời gian chuyến đi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 16),

            // --- Ô CHỌN NGÀY (DESIGN CUSTOM) ---
            GestureDetector(
              onTap: () => _selectDateRange(context, tripData),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  // Viền xanh lá đậm
                  border: Border.all(color: primaryGreen, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.black54),
                    const SizedBox(width: 12),

                    // Text hiển thị ngày
                    Expanded(
                      child: Text(
                        dateText,
                        style: TextStyle(
                          fontSize: 16,
                          color: hasDate ? Colors.black87 : Colors.black54,
                          fontWeight: hasDate ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ),

                    // Icon lịch (Nền xanh)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.calendar_today, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
            ),
            // --------------------------------------------

            const SizedBox(height: 12),

            // Hiển thị số ngày đã tính toán
            if (hasDate)
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text(
                  'Tổng cộng: ${tripData.durationDays} ngày',
                  style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                ),
              ),

            if (!hasDate)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Text(
                    '❗️ Vui lòng chọn ngày đi và về',
                    style: TextStyle(color: Colors.red.shade700, fontSize: 13)
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Nút Back nhỏ
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 12),

            // Nút Tiếp theo
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (!hasDate) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Vui lòng chọn khoảng thời gian!'),
                            backgroundColor: Colors.red
                        )
                    );
                    return;
                  }
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TripLevelScreen())
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                    'Tiếp theo',
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}