import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trip_provider.dart';
import '../utils/vietnam_data.dart'; // Import file dữ liệu 63 tỉnh thành
import 'tripinfopart2.dart';

class TripInfoScreen extends StatelessWidget {
  const TripInfoScreen({super.key});

  final Color primaryGreen = const Color(0xFF4CAF50);
  final Color darkGreen = const Color(0xFF388E3C);

  @override
  Widget build(BuildContext context) {
    // LƯU Ý: Không dùng context.watch() ở đây để tránh vẽ lại toàn bộ màn hình khi gõ chữ

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

              // --- Ô NHẬP LIỆU THÔNG MINH (AUTOCOMPLETE & KHÔNG DẤU) ---
              const _LocationInput(),

              const SizedBox(height: 24),

              // --- CÁC NÚT BẤM (Dùng Consumer để lắng nghe thay đổi màu sắc) ---
              const Text('Loại hình nghỉ ngơi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              Consumer<TripProvider>(
                builder: (context, tripData, _) => Column(
                  children: [
                    _buildChoiceButton(
                      label: 'Cắm trại',
                      isSelected: tripData.accommodation == 'Cắm trại',
                      onTap: () => context.read<TripProvider>().setAccommodation('Cắm trại'),
                      primaryGreen: primaryGreen,
                    ),
                    const SizedBox(height: 12),
                    _buildChoiceButton(
                      label: 'Homestay',
                      isSelected: tripData.accommodation == 'Homestay',
                      onTap: () => context.read<TripProvider>().setAccommodation('Homestay'),
                      primaryGreen: primaryGreen,
                    ),
                    const SizedBox(height: 12),
                    _buildChoiceButton(
                      label: 'Kết hợp',
                      isSelected: tripData.accommodation == 'Kết hợp',
                      onTap: () => context.read<TripProvider>().setAccommodation('Kết hợp'),
                      primaryGreen: primaryGreen,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text('Số người đi cùng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              Consumer<TripProvider>(
                builder: (context, tripData, _) => Column(
                  children: [
                    _buildChoiceButton(
                      label: 'Đơn lẻ (1-2 người)',
                      isSelected: tripData.paxGroup == 'Đơn lẻ (1-2 người)',
                      onTap: () => context.read<TripProvider>().setPaxGroup('Đơn lẻ (1-2 người)'),
                      primaryGreen: primaryGreen,
                    ),
                    const SizedBox(height: 12),
                    _buildChoiceButton(
                      label: 'Nhóm nhỏ (3-6 người)',
                      isSelected: tripData.paxGroup == 'Nhóm nhỏ (3-6 người)',
                      onTap: () => context.read<TripProvider>().setPaxGroup('Nhóm nhỏ (3-6 người)'),
                      primaryGreen: primaryGreen,
                    ),
                    const SizedBox(height: 12),
                    _buildChoiceButton(
                      label: 'Nhóm đông (7+ người)',
                      isSelected: tripData.paxGroup == 'Nhóm đông (7+ người)',
                      onTap: () => context.read<TripProvider>().setPaxGroup('Nhóm đông (7+ người)'),
                      primaryGreen: primaryGreen,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<TripProvider>(
          builder: (context, tripData, _) {
            return ElevatedButton(
              onPressed: () {
                if (tripData.searchLocation.isEmpty || tripData.accommodation == null || tripData.paxGroup == null) {
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildChoiceButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryGreen,
  }) {
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

// --- WIDGET NHẬP LIỆU RIÊNG BIỆT (XỬ LÝ GỢI Ý & KHÔNG DẤU) ---
class _LocationInput extends StatelessWidget {
  const _LocationInput();

  // 1. Hàm tiện ích: Xóa dấu Tiếng Việt để so sánh
  // Đầu vào: "Lào Cai" -> Đầu ra: "lao cai"
  String _removeDiacritics(String str) {
    const withDia = 'áàảãạăắằẳẵặâấầẩẫậđéèẻẽẹêếềểễệíìỉĩịóòỏõọôốồổỗộơớờởỡợúùủũụưứừửữựýỳỷỹỵ';
    const withoutDia = 'aaaaaaaaaaaaaaaaadeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyy';

    str = str.toLowerCase();
    for (int i = 0; i < withDia.length; i++) {
      str = str.replaceAll(withDia[i], withoutDia[i]);
    }
    return str;
  }

  @override
  Widget build(BuildContext context) {
    final initialValue = context.read<TripProvider>().searchLocation;

    return Autocomplete<String>(
      initialValue: TextEditingValue(text: initialValue),

      // 2. Logic lọc dữ liệu THÔNG MINH (Hỗ trợ không dấu)
      optionsBuilder: (TextEditingValue textEditingValue) {
        final inputText = textEditingValue.text;
        if (inputText.isEmpty) {
          return const Iterable<String>.empty();
        }

        // Chuẩn hóa từ khóa nhập vào (bỏ dấu + chữ thường)
        final query = _removeDiacritics(inputText);

        return VietnamData.provinces.where((String option) {
          // Chuẩn hóa tên tỉnh thành trong danh sách (bỏ dấu + chữ thường)
          final optionClean = _removeDiacritics(option);

          // So sánh chuỗi không dấu
          return optionClean.contains(query);
        });
      },

      // 3. Xử lý khi chọn
      onSelected: (String selection) {
        context.read<TripProvider>().setSearchLocation(selection);
        FocusScope.of(context).unfocus(); // Ẩn bàn phím
      },

      // 4. Giao diện ô nhập (Giữ nguyên style cũ)
      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          onChanged: (value) {
            // Cập nhật Provider khi gõ (để lưu cả những từ khóa không có trong list)
            context.read<TripProvider>().setSearchLocation(value);
          },
          decoration: InputDecoration(
            hintText: 'Search (VD: Bình Định...)',
            prefixIcon: const Icon(Icons.search, color: Colors.black54),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey.shade200,
          ),
        );
      },

      // 5. Giao diện List gợi ý
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250, maxWidth: 340),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  return InkWell(
                    onTap: () => onSelected(option),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: index != options.length - 1
                            ? Border(bottom: BorderSide(color: Colors.grey.shade200))
                            : null,
                      ),
                      child: Text(option, style: const TextStyle(fontSize: 15, color: Colors.black87)),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}