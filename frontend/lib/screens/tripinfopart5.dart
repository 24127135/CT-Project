import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/trip_provider.dart';
import '../screens/home_screen.dart';
import 'trip_info_waiting_screen.dart';
import 'home_screen.dart'; // Import HomePage

class TripConfirmScreen extends StatefulWidget {
  const TripConfirmScreen({super.key});
  @override
  State<TripConfirmScreen> createState() => _TripConfirmScreenState();
}

class _TripConfirmScreenState extends State<TripConfirmScreen> {
  final TextEditingController _tripNameController = TextEditingController();
  final Color primaryGreen = const Color(0xFF4CAF50);
  final Color darkGreen = const Color(0xFF388E3C);
  final Color cardBackground = const Color(0xFFC8D7C8);

  @override
  void initState() {
    super.initState();
    final tripData = context.read<TripProvider>();
    _tripNameController.text = tripData.tripName;
  }
  @override
  void dispose() { _tripNameController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final tripData = context.watch<TripProvider>();
    String displayDate = 'Chưa chọn';
    if (tripData.startDate != null && tripData.endDate != null) {
      String start = DateFormat('dd/MM/yyyy').format(tripData.startDate!);
      String end = DateFormat('dd/MM/yyyy').format(tripData.endDate!);
      displayDate = '$start - $end (${tripData.durationDays} ngày)';
    }

    return Scaffold(
      appBar: AppBar(
        // Nút Hủy về Home
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // FIXED: Top Left goes to Home
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
              (route) => false,
            );
          },
        ),
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Thông tin chuyến đi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)), Text('Bước 5/5', style: TextStyle(color: Colors.white70, fontSize: 14))]),
        backgroundColor: darkGreen, elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            const Text('Xác nhận thông tin', style: TextStyle(color: Colors.redAccent, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Hãy kiểm tra lại kĩ thông tin trước khi xác nhận!', style: TextStyle(color: Colors.black54, fontSize: 14)),
            const SizedBox(height: 24),

            Align(alignment: Alignment.centerLeft, child: const Text('Đặt tên cho chuyến đi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            const SizedBox(height: 8),
            TextField(
              controller: _tripNameController,
              onChanged: (value) => context.read<TripProvider>().setTripName(value),
              decoration: InputDecoration(
                hintText: 'Ví dụ: Chuyến đi săn mây Tà Xùa',
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.green)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.green)),
                filled: true,
                fillColor: const Color(0xFFF9FFF9),
              ),
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: cardBackground, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade400)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryItem('Địa điểm', tripData.searchLocation.isEmpty ? 'Chưa chọn' : tripData.searchLocation),
                  _buildSummaryItem('Thời gian', displayDate),
                  _buildSummaryItem('Loại hình ngủ nghỉ', tripData.accommodation ?? 'Chưa chọn'),
                  _buildSummaryItem('Số người', tripData.paxGroup ?? 'Chưa chọn'),
                  _buildSummaryItem('Độ khó', tripData.difficultyLevel ?? 'Chưa chọn'),
                  if (tripData.selectedInterests.isNotEmpty)
                    Padding(padding: const EdgeInsets.only(top: 8.0), child: _buildSummaryItem('Sở thích', tripData.selectedInterests.join(', '))),
                  if (tripData.note.isNotEmpty)
                    Padding(padding: const EdgeInsets.only(top: 8.0), child: _buildSummaryItem('Ghi chú', tripData.note)),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0,1))]),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
                onPressed: () => Navigator.pop(context), // Bottom Left Button (Back to Step 4)
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    String tName = tripData.tripName.isEmpty ? "Mẫu mới ${DateTime.now().minute}" : tripData.tripName;
                    await context.read<TripProvider>().saveHistoryInput(tName);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu mẫu thành công!'), backgroundColor: Colors.green));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi lưu: $e'), backgroundColor: Colors.red));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black87, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade300)), elevation: 1),
                child: const Text('Lưu mẫu này', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const WaitingScreen()));
                },
                style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 2),
                child: const Text('Xác nhận', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildSummaryItem(String label, String value) {
    return Padding(padding: const EdgeInsets.only(bottom: 12.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 15)), const SizedBox(height: 2), Text(value, style: TextStyle(color: Colors.grey.shade700, fontSize: 15, height: 1.3))]));
  }
}