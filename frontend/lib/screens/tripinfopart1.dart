import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trip_provider.dart';
import 'tripinfopart2.dart';

class TripInfoScreen extends StatefulWidget {
  const TripInfoScreen({super.key});

  @override
  State<TripInfoScreen> createState() => _TripInfoScreenState();
}

class _TripInfoScreenState extends State<TripInfoScreen> {
  final Color primaryGreen = const Color(0xFF4CAF50);
  final Color darkGreen = const Color(0xFF388E3C);

  // 1. Define Controller here
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    // 2. Initialize controller ONCE with data from Provider
    final tripData = context.read<TripProvider>();
    _locationController = TextEditingController(text: tripData.searchLocation);
  }

  @override
  void dispose() {
    // 3. Dispose controller to free memory
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tripData = context.watch<TripProvider>();

    // Optional: If the provider updates from elsewhere (reset), sync the controller
    if (_locationController.text != tripData.searchLocation) {
       _locationController.text = tripData.searchLocation;
       // Keep cursor at end to prevent jumping if updated externally
       _locationController.selection = TextSelection.fromPosition(
           TextPosition(offset: _locationController.text.length)
       );
    }

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
            Text('Bước 1/5', style: TextStyle(color: Colors.white70, fontSize: 14)),
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
              const Text('Địa điểm trekking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // Ô nhập địa điểm
              TextField(
                // 4. Use the persistent controller
                controller: _locationController,
                onChanged: (value) {
                  // Only update provider, DO NOT recreate controller
                  context.read<TripProvider>().setSearchLocation(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search (VD: Tà Xùa)',
                  prefixIcon: const Icon(Icons.search, color: Colors.black54),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                ),
              ),

              const SizedBox(height: 24),

              const Text('Loại hình nghỉ ngơi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              _buildChoiceButton(
                label: 'Cắm trại',
                isSelected: tripData.accommodation == 'Cắm trại',
                onTap: () => context.read<TripProvider>().setAccommodation('Cắm trại'),
              ),
              const SizedBox(height: 12),
              _buildChoiceButton(
                label: 'Homestay',
                isSelected: tripData.accommodation == 'Homestay',
                onTap: () => context.read<TripProvider>().setAccommodation('Homestay'),
              ),
              const SizedBox(height: 12),
              _buildChoiceButton(
                label: 'Kết hợp',
                isSelected: tripData.accommodation == 'Kết hợp',
                onTap: () => context.read<TripProvider>().setAccommodation('Kết hợp'),
              ),

              const SizedBox(height: 24),

              const Text('Số người đi cùng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              _buildChoiceButton(
                label: 'Đơn lẻ (1-2 người)',
                isSelected: tripData.paxGroup == 'Đơn lẻ (1-2 người)',
                onTap: () => context.read<TripProvider>().setPaxGroup('Đơn lẻ (1-2 người)'),
              ),
              const SizedBox(height: 12),
              _buildChoiceButton(
                label: 'Nhóm nhỏ (3-6 người)',
                isSelected: tripData.paxGroup == 'Nhóm nhỏ (3-6 người)',
                onTap: () => context.read<TripProvider>().setPaxGroup('Nhóm nhỏ (3-6 người)'),
              ),
              const SizedBox(height: 12),
              _buildChoiceButton(
                label: 'Nhóm đông (7+ người)',
                isSelected: tripData.paxGroup == 'Nhóm đông (7+ người)',
                onTap: () => context.read<TripProvider>().setPaxGroup('Nhóm đông (7+ người)'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            if (tripData.accommodation == null || tripData.paxGroup == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vui lòng chọn đủ thông tin!'), backgroundColor: Colors.red),
              );
              return;
            }
            Navigator.push(context, MaterialPageRoute(builder: (context) => const TripTimeScreen()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Tiếp theo', style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildChoiceButton({required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? primaryGreen : Colors.white,
          border: Border.all(color: isSelected ? primaryGreen : Colors.grey.shade300, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            label,
            style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }
}