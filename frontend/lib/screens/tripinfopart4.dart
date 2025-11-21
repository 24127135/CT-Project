import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trip_provider.dart';
import 'tripinfopart5.dart';

class TripRequestScreen extends StatefulWidget {
  const TripRequestScreen({super.key});

  @override
  State<TripRequestScreen> createState() => _TripRequestScreenState();
}

class _TripRequestScreenState extends State<TripRequestScreen> {
  late TextEditingController _noteController;
  final Color primaryGreen = const Color(0xFF4CAF50);
  final Color darkGreen = const Color(0xFF388E3C);

  final List<String> _suggestedInterests = [
    'Rừng nguyên sinh', 'Ngắm hoàng hôn', 'Ăn chay',
    'Ngắm bình minh', 'Tiệc BBQ ngoài trời', 'Dị ứng hải sản',
    'Tìm hiểu văn hóa địa phương', 'Chụp ảnh phong cảnh',
    'Leo núi', 'Tắm suối', 'Thiền / Yoga'
  ];

  @override
  void initState() {
    super.initState();
    // Lấy dữ liệu cũ (nếu có) từ Provider để điền vào ô nhập
    final note = context.read<TripProvider>().note;
    _noteController = TextEditingController(text: note);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe dữ liệu
    final tripData = context.watch<TripProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thông tin chuyến đi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Bước 4/5', style: TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
        backgroundColor: darkGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Yêu cầu cá nhân', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            TextField(
              controller: _noteController,
              // Lưu vào Provider mỗi khi gõ
              onChanged: (value) => context.read<TripProvider>().setNote(value),
              maxLines: 6,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Nhập yêu cầu của bạn...',
                fillColor: const Color(0xFFF1F8E9),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade400)),
              ),
            ),

            const SizedBox(height: 24),

            // --- SỞ THÍCH ĐÃ CHỌN ---
            if (tripData.selectedInterests.isNotEmpty) ...[
              const Text('Sở thích đã chọn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: tripData.selectedInterests.map((interest) {
                  return _buildSelectedChip(context, interest);
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // --- GỢI Ý SỞ THÍCH ---
            const Text('Gợi ý sở thích', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _suggestedInterests.map((interest) {
                // Nếu đã chọn rồi thì ẩn khỏi danh sách gợi ý
                if (tripData.selectedInterests.contains(interest)) return const SizedBox.shrink();
                return _buildSuggestionChip(context, interest);
              }).toList(),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
              child: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const TripConfirmScreen()));
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

  Widget _buildSuggestionChip(BuildContext context, String label) {
    return GestureDetector(
      // Gọi hàm toggleInterest từ Provider
      onTap: () => context.read<TripProvider>().toggleInterest(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: primaryGreen.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text('+ $label', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildSelectedChip(BuildContext context, String label) {
    return GestureDetector(
      // Gọi hàm toggleInterest từ Provider (để xóa)
      onTap: () => context.read<TripProvider>().toggleInterest(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: primaryGreen,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            const Icon(Icons.close, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}