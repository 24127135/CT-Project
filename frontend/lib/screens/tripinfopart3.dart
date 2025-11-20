import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trip_provider.dart';
import 'tripinfopart4.dart';

class TripLevelScreen extends StatefulWidget {
  const TripLevelScreen({super.key});

  @override
  State<TripLevelScreen> createState() => _TripLevelScreenState();
}

class _TripLevelScreenState extends State<TripLevelScreen> {
  // Định nghĩa các màu sắc
  final Color primaryGreen = const Color(0xFF4CAF50);
  final Color darkGreen = const Color(0xFF388E3C);
  final Color levelGreen = const Color(0xFF4CAF50);
  final Color levelOrange = const Color(0xFFFF7043);
  final Color levelRed = const Color(0xFFF44336);

  @override
  Widget build(BuildContext context) {
    // Lắng nghe dữ liệu từ Provider
    final tripData = context.watch<TripProvider>();

    return Scaffold(
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
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Bước 3/5',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        backgroundColor: darkGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Card 1: Người mới
              _buildLevelCard(
                title: 'Người mới',
                description: 'Đường mòn rõ ràng, độ dốc nhẹ, phù hợp cho người mới bắt đầu. Khoảng cách ngắn (5-10km/ngày), độ cao dưới 1500m.',
                themeColor: levelGreen,
                value: 'Người mới',
                currentSelection: tripData.difficultyLevel, // Lấy từ Provider
                onTap: () => context.read<TripProvider>().setDifficultyLevel('Người mới'), // Lưu vào Provider
              ),
              const SizedBox(height: 16),

              // Card 2: Có kinh nghiệm
              _buildLevelCard(
                title: 'Có kinh nghiệm',
                description: 'Địa hình đa dạng, độ dốc vừa phải, yêu cầu thể lực tốt, có tập luyện thường xuyên. Khoảng cách 10-15km/ngày, độ cao 1500m-2500m.',
                themeColor: levelOrange,
                value: 'Có kinh nghiệm',
                currentSelection: tripData.difficultyLevel,
                onTap: () => context.read<TripProvider>().setDifficultyLevel('Có kinh nghiệm'),
              ),
              const SizedBox(height: 16),

              // Card 3: Chuyên nghiệp
              _buildLevelCard(
                title: 'Chuyên nghiệp',
                description: 'Địa hình hiểm trở, độ dốc cao, yêu cầu có hiểu biết về kỹ thuật và tập luyện cường độ cao. Khoảng cách trên 15km/ngày, độ cao trên 2500m.',
                themeColor: levelRed,
                value: 'Chuyên nghiệp',
                currentSelection: tripData.difficultyLevel,
                onTap: () => context.read<TripProvider>().setDifficultyLevel('Chuyên nghiệp'),
              ),

              const SizedBox(height: 24),

              // Hộp Lời khuyên
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.yellow.shade700, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Lời khuyên:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Nếu bạn là người mới, hãy bắt đầu với các tuyến đường dễ để làm quen với trekking. Luôn đi cùng người có kinh nghiệm trong những chuyến đầu tiên!',
                      style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (tripData.difficultyLevel == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn mức độ!'), backgroundColor: Colors.red));
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TripRequestScreen()),
                  );
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

  // --- WIDGET CARD (Đã khôi phục logic đổi màu chuẩn) ---
  Widget _buildLevelCard({
    required String title,
    required String description,
    required Color themeColor,
    required String value,
    required String? currentSelection, // Nhận giá trị từ Provider
    required VoidCallback onTap,
  }) {
    final bool isSelected = currentSelection == value; // Kiểm tra xem có đang được chọn không

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? themeColor : Colors.white,
          border: Border.all(color: themeColor, width: 1.5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [
            BoxShadow(color: themeColor.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))
          ] : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề
            Text(
              title,
              style: TextStyle(
                // Logic màu chữ: Nếu chọn -> Trắng, Nếu không -> Màu theme
                color: isSelected ? Colors.white : themeColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            // Mô tả
            Text(
              description,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}