import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/pec_provider.dart';
import '../widgets/pec_item_widget.dart';
import '../widgets/add_item_modal.dart';

class PecScreen extends StatelessWidget {
  const PecScreen({super.key});

  final Color primaryGreen = const Color(0xFF66BB6A);
  final Color lightGrey = const Color(0xFFF5F5F5);
  final Color darkText = const Color(0xFF333333);
  final Color lightText = const Color(0xFF888888);
  final Color priceColor = const Color(0xFFF44336);

  @override
  Widget build(BuildContext context) {
    final pecProvider = context.watch<PecProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: darkText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Danh sách đồ dùng',
          style: TextStyle(
            color: darkText,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (value) => context.read<PecProvider>().setSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm đồ dùng...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: lightGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) => const AddItemModal(),
          );
        },
        backgroundColor: primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildCategoryTabs(context, pecProvider),
          _buildFilterChips(context, pecProvider),
          if (pecProvider.isPriceFilterVisible) _buildPriceFilter(context, pecProvider),
          Expanded(child: _buildItemList(context, pecProvider)),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, pecProvider),
    );
  }

  Widget _buildCategoryTabs(BuildContext context, PecProvider pecProvider) {
    final categories = ['Quần áo', 'Phụ kiện', 'Dụng cụ', 'Thực phẩm'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: categories.map((cat) {
          final isSelected = pecProvider.selectedCategory == cat;
          return Expanded(
            child: GestureDetector(
              onTap: () => context.read<PecProvider>().setCategory(cat),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? primaryGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  cat,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF666666),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, PecProvider pecProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => context.read<PecProvider>().setSort('Xem theo giá'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: primaryGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Xem theo giá',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ...['Giá Thấp - Cao', 'Giá Cao - Thấp'].map((opt) {
            final isSelected = pecProvider.selectedSort == opt;
            return Expanded(
              child: GestureDetector(
                onTap: () => context.read<PecProvider>().setSort(opt),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryGreen : const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    opt,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF666666),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPriceFilter(BuildContext context, PecProvider pecProvider) {
    final NumberFormat currencyFormatter = NumberFormat('#,##0', 'vi_VN');
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300)
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${currencyFormatter.format(pecProvider.priceRange.start)} đ', style: TextStyle(color: darkText, fontWeight: FontWeight.bold)),
              Text('${currencyFormatter.format(pecProvider.priceRange.end)} đ', style: TextStyle(color: darkText, fontWeight: FontWeight.bold)),
            ],
          ),
          RangeSlider(
            values: pecProvider.priceRange,
            min: 0,
            max: 42000000,
            divisions: 100,
            activeColor: primaryGreen,
            inactiveColor: Colors.grey.shade300,
            labels: RangeLabels(
              currencyFormatter.format(pecProvider.priceRange.start),
              currencyFormatter.format(pecProvider.priceRange.end),
            ),
            onChanged: (RangeValues values) {
              context.read<PecProvider>().setPriceRange(values);
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  context.read<PecProvider>().setSort('Giá Thấp - Cao');
                },
                child: Text("Đóng", style: TextStyle(color: darkText))
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<PecProvider>().setSort('Giá Thấp - Cao');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text("Xem kết quả", style: TextStyle(color: Colors.white)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildItemList(BuildContext context, PecProvider pecProvider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: pecProvider.items.length,
      itemBuilder: (context, index) {
        final item = pecProvider.items[index];
        return PecItemWidget(item: item);
      },
    );
  }

  Widget _buildBottomBar(BuildContext context, PecProvider pecProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tổng cộng:', style: TextStyle(color: lightText, fontSize: 14)),
                  Consumer<PecProvider>(
                    builder: (context, provider, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.totalPrice,
                            style: TextStyle(
                              color: priceColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${(provider.totalWeight / 1000).toStringAsFixed(1)} kg',
                            style: TextStyle(
                              color: darkText,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement confirmation logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Xác nhận',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
