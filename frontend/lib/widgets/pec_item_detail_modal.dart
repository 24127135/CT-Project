import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/pec_provider.dart';

class PecItemDetailModal extends StatelessWidget {
  final Map<String, dynamic> item;

  const PecItemDetailModal({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final pecProvider = context.read<PecProvider>();
    final NumberFormat currencyFormatter = NumberFormat('#,##0', 'vi_VN');
    final Color primaryGreen = const Color(0xFF66BB6A);
    final Color darkText = const Color(0xFF333333);
    final Color lightText = const Color(0xFF888888);
    final Color priceColor = const Color(0xFFF44336);

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

          // Image
          Center(
            child: Container(
              width: 150,
              height: 150,
              color: Colors.grey.shade100,
              child: const Center(child: Text("PNG", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
            ),
          ),
          const SizedBox(height: 24),

          // Name & Store
          Text(
            item['name'],
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item['store'],
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: lightText,
            ),
          ),
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
              item['description'] ?? 'Không có mô tả.',
              style: TextStyle(color: darkText, height: 1.5),
            ),
          ),
          const SizedBox(height: 24),

          // Price & Quantity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${currencyFormatter.format(item['price'])} đ',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: priceColor,
                ),
              ),
              Row(
                children: [
                  _buildQuantityButton(
                    icon: Icons.remove,
                    onTap: () {
                      if (item['quantity'] > 1) {
                         pecProvider.updateQuantity(item['id'], item['quantity'] - 1);
                         // Since the modal is stateless and item is passed once, 
                         // we might need to listen to provider updates or just close/reopen.
                         // Ideally, we should use a Consumer here to update the quantity text in real-time.
                      }
                    },
                  ),
                  const SizedBox(width: 16),
                  Consumer<PecProvider>(
                    builder: (context, provider, child) {
                      // Find the updated item to show current quantity
                      final updatedItem = provider.items.firstWhere((i) => i['id'] == item['id'], orElse: () => item);
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
                      pecProvider.updateQuantity(item['id'], item['quantity'] + 1);
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
