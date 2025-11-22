import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trip_provider.dart';
import '../features/home/screen/home_view.dart';
import 'tripinfopart4.dart';

class TripLevelScreen extends StatelessWidget {
  const TripLevelScreen({super.key});

  final Color primaryGreen = const Color(0xFF4CAF50);
  final Color darkGreen = const Color(0xFF388E3C);

  @override
  Widget build(BuildContext context) {
    final tripData = context.watch<TripProvider>();

    return Scaffold(
      appBar: AppBar(
        // Nút Hủy về Home
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            context.read<TripProvider>().resetTrip();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomeView()),
                  (Route<dynamic> route) => false,
            );
          },
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thông tin chuyến đi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Bước 3/5', style: TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
        backgroundColor: darkGreen, elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Các nút chọn cấp độ
            _buildLevelCard(
              title: 'Người mới',
              description: 'Đường mòn rõ ràng, độ dốc nhẹ, ít thử thách kỹ thuật. Thích hợp cho lần đầu làm quen trekking.',
              color: Colors.green,
              isSelected: tripData.difficultyLevel == 'Người mới',
              onTap: () => context.read<TripProvider>().setDifficultyLevel('Người mới'),
            ),
            const SizedBox(height: 12),
            _buildLevelCard(
              title: 'Có kinh nghiệm',
              description: 'Địa hình đa dạng, độ dốc vừa phải, có thể có đoạn trơn trượt hoặc cần leo trèo nhẹ. Cần thể lực tốt.',
              color: Colors.orange,
              isSelected: tripData.difficultyLevel == 'Có kinh nghiệm',
              onTap: () => context.read<TripProvider>().setDifficultyLevel('Có kinh nghiệm'),
            ),
            const SizedBox(height: 12),
            _buildLevelCard(
              title: 'Chuyên nghiệp',
              description: 'Địa hình hiểm trở, độ dốc cao, đường đi phức tạp, có thể cần kỹ năng sinh tồn và định vị. Chỉ dành cho trekker dày dạn.',
              color: Colors.red,
              isSelected: tripData.difficultyLevel == 'Chuyên nghiệp',
              onTap: () => context.read<TripProvider>().setDifficultyLevel('Chuyên nghiệp'),
            ),

            const SizedBox(height: 20),

            // --- PHẦN LỜI KHUYÊN (DESIGN GỐC ĐÃ ĐƯỢC KHÔI PHỤC) ---

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50, // Nền xanh nhạt
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade100), // Viền xanh nhẹ
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb, color: Colors.amber), // Icon bóng đèn vàng
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Lời khuyên:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          'Nếu bạn là người mới, hãy bắt đầu với các tuyến đường dễ để làm quen. Đừng quên rèn luyện thể lực trước chuyến đi!',
                          style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
            // -------------------------------------------------------
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Nút Back dưới
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black54),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 12),
            // Nút Tiếp theo
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (tripData.difficultyLevel == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng chọn mức độ!'), backgroundColor: Colors.red),
                    );
                    return;
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const TripRequestScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Tiếp theo', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard({required String title, required String description, required Color color, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.4)),
          ],
        ),
      ),
    );
  }
}