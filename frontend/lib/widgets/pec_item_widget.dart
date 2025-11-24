import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/pec_provider.dart';
import 'pec_item_detail_modal.dart';

class PecItemWidget extends StatelessWidget {
  final Map<String, dynamic> item;

  const PecItemWidget({super.key, required this.item});

  final Color primaryGreen = const Color(0xFF66BB6A);
  final Color lightGrey = const Color(0xFFF5F5F5);
  final Color darkText = const Color(0xFF333333);
  final Color lightText = const Color(0xFF888888);
  final Color priceColor = const Color(0xFFF44336);

  @override
  Widget build(BuildContext context) {
    final pecProvider = context.read<PecProvider>();
    final NumberFormat currencyFormatter = NumberFormat('#,##0', 'vi_VN');

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: lightGrey.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => PecItemDetailModal(item: item),
          );
        },
        leading: Checkbox(
          value: item['checked'],
          onChanged: (bool? value) {
            pecProvider.toggleItemChecked(item['id']);
          },
          activeColor: primaryGreen,
        ),
        title: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              color: Colors.grey.shade300,
              child: const Center(child: Text("PNG")), // Placeholder for image
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['name'], style: TextStyle(fontWeight: FontWeight.bold, color: darkText)),
                  Text(item['store'], style: TextStyle(color: lightText, fontSize: 12)),
                  Text('${currencyFormatter.format(item['price'])} đ', style: TextStyle(color: priceColor, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(icon: const Icon(Icons.add), onPressed: () {
                  pecProvider.updateQuantity(item['id'], item['quantity'] + 1);
                }),
                Text('${item['quantity']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.remove), onPressed: () {
                  pecProvider.updateQuantity(item['id'], item['quantity'] - 1);
                }),
              ],
            )
          ],
        ),
      ),
    );
  }
}
