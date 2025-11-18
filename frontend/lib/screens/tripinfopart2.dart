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

  Future<void> _selectDate(BuildContext context, TripProvider tripData) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      // Lấy ngày hiện tại đã lưu trong Provider làm ngày mặc định (nếu có)
      initialDate: tripData.startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryGreen,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: darkGreen),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // LƯU VÀO PROVIDER
      context.read<TripProvider>().setStartDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    // LẮNG NGHE DỮ LIỆU TỪ PROVIDER
    final tripData = context.watch<TripProvider>();

    final String formattedDate = tripData.startDate == null
        ? 'MM/DD/YYYY'
        : DateFormat('dd/MM/yyyy').format(tripData.startDate!);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thông tin chuyến đi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Bước 2/5', style: TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
        backgroundColor: darkGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Thời gian chuyến đi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              GestureDetector(
                onTap: () => _selectDate(context, tripData), // Truyền tripData vào hàm
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
                      Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey.shade600),
                          const SizedBox(width: 12),
                          Text(
                            formattedDate, // Hiển thị ngày từ Provider
                            style: TextStyle(
                              fontSize: 16,
                              color: tripData.startDate == null ? Colors.grey.shade600 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Icon(Icons.calendar_month, color: primaryGreen),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),
              if (tripData.startDate == null)
                Text('❗️ Hãy chọn đủ các thông tin bắt buộc', style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (tripData.startDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn ngày!'), backgroundColor: Colors.red));
                    return;
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const TripLevelScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Tiếp theo', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}