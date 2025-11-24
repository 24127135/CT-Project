import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/pec_provider.dart';

class PecItemDetailModal extends StatefulWidget {
  final Map<String, dynamic> item;

  const PecItemDetailModal({super.key, required this.item});

  @override
  State<PecItemDetailModal> createState() => _PecItemDetailModalState();
}

class _PecItemDetailModalState extends State<PecItemDetailModal> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pecProvider = context.read<PecProvider>();
    final NumberFormat currencyFormatter = NumberFormat('#,##0', 'vi_VN');
    final Color primaryGreen = const Color(0xFF66BB6A);
    final Color darkText = const Color(0xFF333333);
    final Color lightText = const Color(0xFF888888);
    final Color priceColor = const Color(0xFFF44336);

    final List<String> images = (widget.item['images'] as List<String>?) ?? [];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Image Gallery
          if (images.isNotEmpty) ...[
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: images.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(images[index]),
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Page Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index ? primaryGreen : Colors.grey.shade300,
                  ),
                );
              }),
            ),
          ] else ...[
            // Placeholder if no images
            Center(
              child: Container(
                width: 150,
                height: 150,
                color: Colors.grey.shade100,
                child: const Center(child: Text("PNG", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Name & Store
          Text(
            widget.item['name'],
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.item['store'],
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: lightText,
            ),
          ),
          if (widget.item['weight'] != null && widget.item['weight'] > 0) ...[
            const SizedBox(height: 4),
            Text(
              'Khối lượng: ${widget.item['weight']}g',
              style: TextStyle(
                fontSize: 14,
                color: lightText,
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Description Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.item['description'] ?? 'Không có mô tả.',
              style: TextStyle(color: darkText, height: 1.5),
            ),
          ),
          const SizedBox(height: 24),

          // Price & Quantity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Consumer<PecProvider>(
                builder: (context, provider, child) {
                  final updatedItem = provider.items.firstWhere((i) => i['id'] == widget.item['id'], orElse: () => widget.item);
                  return Text(
                    '${currencyFormatter.format(updatedItem['price'] * (updatedItem['quantity'] > 0 ? updatedItem['quantity'] : 1))} đ',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: priceColor,
                    ),
                  );
                },
              ),
              Row(
                children: [
                  _buildQuantityButton(
                    icon: Icons.remove,
                    onTap: () {
                      if (widget.item['quantity'] > 1) {
                         pecProvider.updateQuantity(widget.item['id'], widget.item['quantity'] - 1);
                      }
                    },
                  ),
                  const SizedBox(width: 16),
                  Consumer<PecProvider>(
                    builder: (context, provider, child) {
                      // Find the updated item to show current quantity
                      final updatedItem = provider.items.firstWhere((i) => i['id'] == widget.item['id'], orElse: () => widget.item);
                      return Text(
                        '${updatedItem['quantity']}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  _buildQuantityButton(
                    icon: Icons.add,
                    onTap: () {
                      pecProvider.updateQuantity(widget.item['id'], widget.item['quantity'] + 1);
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: Colors.black),
      ),
    );
  }
}
