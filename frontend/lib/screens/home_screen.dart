import 'package:flutter/material.dart';
import 'tripinfopart1.dart'; // Import the Trip Info Screen (Step 1)

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // State to track if the "Plan" card is expanded
  bool _isPlanExpanded = false;

  // Define the Green Color from the design
  final Color _forestGreen = const Color(0xFF425E3C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 1. HEADER SECTION
          Expanded(
            flex: 4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Green Background Top
                Container(
                  color: _forestGreen,
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.only(top: 60),
                  child: Text(
                    "HOME PAGE",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900, // Extra bold to match ArchivoBlack
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                // Image Overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 200,
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        // Using a placeholder mountain image
                        image: NetworkImage(
                            'https://images.unsplash.com/photo-1506617524003-b71686086a0b?q=80&w=1000&auto=format&fit=crop'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      // Gradient to make text readable
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Khám phá thiên nhiên Việt Nam",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Hãy bắt đầu hành trình",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. BODY SECTION
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  // Card 1: Lên kế hoạch (Expandable)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isPlanExpanded = !_isPlanExpanded;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: _isPlanExpanded ? _forestGreen : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Top part of card (Always visible)
                          _buildCardContent(
                            icon: Icons.map_outlined,
                            title: "Lên kế hoạch",
                            subtitle: "Nhập thông tin chuyến đi mới",
                            isDarkBg: _isPlanExpanded,
                          ),
                          
                          // Expanded Content (Buttons)
                          if (_isPlanExpanded) ...[
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildActionButton(
                                    "Tạo mới",
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          // Navigating to Step 1 (TripInfoScreen)
                                          builder: (context) => const TripInfoScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: _buildActionButton(
                                    "Nhập nhanh",
                                    onTap: () {
                                      // Placeholder for "Nhập nhanh" action
                                      print("Nhập nhanh pressed");
                                    },
                                  ),
                                ),
                              ],
                            )
                          ]
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Card 2: Chuyến đi đã tạo
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: _buildCardContent(
                      icon: Icons.receipt_long_outlined,
                      title: "Chuyến đi đã tạo",
                      subtitle: "Xem các kế hoạch đã lưu",
                      isDarkBg: false,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Footer Tip
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb_outline,
                          color: Colors.yellow[700], size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 13),
                            children: const [
                              TextSpan(
                                text: "Mẹo: ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text:
                                    "Luôn kiểm tra thời tiết và chuẩn bị đầy đủ trang thiết bị trước khi lên đường!",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build the content inside the main cards
  Widget _buildCardContent({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDarkBg,
  }) {
    return Container(
        decoration: BoxDecoration(
            color: isDarkBg ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(15)
        ),
        padding: isDarkBg ? const EdgeInsets.all(15) : EdgeInsets.zero,
        child: Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _forestGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _forestGreen,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }

  // Helper for the white buttons inside the expanded green card
  // Updated to accept an onTap callback
  Widget _buildActionButton(String text, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: _forestGreen,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}