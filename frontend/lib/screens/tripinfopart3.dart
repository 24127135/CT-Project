import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trip_provider.dart';
import '../features/home/screen/home_view.dart';
import 'tripinfopart4.dart';
import 'home_screen.dart'; // Import HomePage

class TripLevelScreen extends StatelessWidget {
  const TripLevelScreen({super.key});

<<<<<<< HEAD
  @override
  State<TripLevelScreen> createState() => _TripLevelScreenState();
}

class _TripLevelScreenState extends State<TripLevelScreen> {
=======
>>>>>>> DB-RouteProfile
  final Color primaryGreen = const Color(0xFF4CAF50);
  final Color darkGreen = const Color(0xFF388E3C);

  @override
  Widget build(BuildContext context) {
    final tripData = context.watch<TripProvider>();

    return Scaffold(
      appBar: AppBar(
        // Nút Hủy về Home
        leading: IconButton(
<<<<<<< HEAD
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // FIXED: Top Left goes to Home
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
              (route) => false,
=======
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            context.read<TripProvider>().resetTrip();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomeView()),
                  (Route<dynamic> route) => false,
>>>>>>> DB-RouteProfile
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
<<<<<<< HEAD
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildLevelCard(
                title: 'Người mới',
                description: 'Đường mòn rõ ràng, độ dốc nhẹ, phù hợp cho người mới bắt đầu. Khoảng cách ngắn (5-10km/ngày), độ cao dưới 1500m.',
                themeColor: levelGreen,
                value: 'Người mới',
                currentSelection: tripData.difficultyLevel,
                onTap: () => context.read<TripProvider>().setDifficultyLevel('Người mới'),
              ),
              const SizedBox(height: 16),
              _buildLevelCard(
                title: 'Có kinh nghiệm',
                description: 'Địa hình đa dạng, độ dốc vừa phải, yêu cầu thể lực tốt, có tập luyện thường xuyên. Khoảng cách 10-15km/ngày, độ cao 1500m-2500m.',
                themeColor: levelOrange,
                value: 'Có kinh nghiệm',
                currentSelection: tripData.difficultyLevel,
                onTap: () => context.read<TripProvider>().setDifficultyLevel('Có kinh nghiệm'),
              ),
              const SizedBox(height: 16),
              _buildLevelCard(
                title: 'Chuyên nghiệp',
                description: 'Địa hình hiểm trở, độ dốc cao, yêu cầu có hiểu biết về kỹ thuật và tập luyện cường độ cao. Khoảng cách trên 15km/ngày, độ cao trên 2500m.',
                themeColor: levelRed,
                value: 'Chuyên nghiệp',
                currentSelection: tripData.difficultyLevel,
                onTap: () => context.read<TripProvider>().setDifficultyLevel('Chuyên nghiệp'),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFF1F8E9), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [Icon(Icons.lightbulb, color: Colors.yellow.shade700, size: 20), const SizedBox(width: 8), const Text('Lời khuyên:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))]),
                    const SizedBox(height: 8),
                    const Text('Nếu bạn là người mới, hãy bắt đầu với các tuyến đường dễ để làm quen với trekking. Luôn đi cùng người có kinh nghiệm trong những chuyến đầu tiên!', style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.4)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
=======
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
>>>>>>> DB-RouteProfile
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Nút Back dưới
            Container(
<<<<<<< HEAD
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.pop(context), // Bottom Left Button (Back to Step 2)
=======
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black54),
                onPressed: () => Navigator.pop(context),
>>>>>>> DB-RouteProfile
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
<<<<<<< HEAD
                style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
=======
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
>>>>>>> DB-RouteProfile
                child: const Text('Tiếp theo', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildLevelCard({required String title, required String description, required Color themeColor, required String value, required String? currentSelection, required VoidCallback onTap}) {
    final bool isSelected = currentSelection == value;
=======
  Widget _buildLevelCard({required String title, required String description, required Color color, required bool isSelected, required VoidCallback onTap}) {
>>>>>>> DB-RouteProfile
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
<<<<<<< HEAD
        decoration: BoxDecoration(color: isSelected ? themeColor : Colors.white, border: Border.all(color: themeColor, width: 1.5), borderRadius: BorderRadius.circular(12), boxShadow: isSelected ? [BoxShadow(color: themeColor.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))] : []),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: isSelected ? Colors.white : themeColor, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(description, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 13, height: 1.4)),
=======
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
>>>>>>> DB-RouteProfile
          ],
        ),
      ),
    );
  }
}