import 'package:flutter/material.dart';

class PecProvider with ChangeNotifier {
  // final String _jwtToken;
  // PecProvider(this._jwtToken);

  // TODO: Replace with actual data fetching
  List<Map<String, dynamic>> _items = [
    {
      'id': 1, 
      'name': 'Áo khoác chống nước', 
      'store': 'Decathlon', 
      'price': 999000, 
      'quantity': 1, 
      'checked': false, 
      'category': 'Quần áo',
      'description': 'Áo khoác chống nước nhẹ, thoáng khí, thích hợp cho đi bộ đường dài và du lịch bụi. Có mũ trùm đầu có thể điều chỉnh và túi khóa kéo tiện lợi.'
    },
    {
      'id': 2, 
      'name': 'Quần trekking', 
      'store': 'The North Face', 
      'price': 1500000, 
      'quantity': 2, 
      'checked': false, 
      'category': 'Quần áo',
      'description': 'Quần trekking co giãn 4 chiều, khô nhanh, chống thấm nước nhẹ. Thiết kế tiện dụng với nhiều túi và đai lưng có thể điều chỉnh.'
    },
    {
      'id': 3, 
      'name': 'Giày leo núi', 
      'store': 'Salomon', 
      'price': 2500000, 
      'quantity': 1, 
      'checked': true, 
      'category': 'Phụ kiện',
      'description': 'Giày leo núi bền bỉ, đế cao su chống trượt tốt trên mọi địa hình. Lớp lót êm ái giúp bảo vệ chân trong những chuyến đi dài.'
    },
    {
      'id': 4, 
      'name': 'Balo 40L', 
      'store': 'Osprey', 
      'price': 3200000, 
      'quantity': 1, 
      'checked': false, 
      'category': 'Dụng cụ',
      'description': 'Balo du lịch 40L với hệ thống đệm lưng thoáng khí Anti-Gravity. Ngăn chứa rộng rãi, có ngăn riêng cho túi ngủ và áo mưa.'
    },
    {
      'id': 5, 
      'name': 'Lều 2 người', 
      'store': 'Naturehike', 
      'price': 1800000, 
      'quantity': 1, 
      'checked': false, 
      'category': 'Dụng cụ',
      'description': 'Lều cắm trại 2 người siêu nhẹ, chống thấm nước PU3000mm. Khung nhôm chắc chắn, dễ dàng lắp đặt và tháo dỡ.'
    },
    {
      'id': 6, 
      'name': 'Thanh năng lượng', 
      'store': 'GU Energy', 
      'price': 50000, 
      'quantity': 5, 
      'checked': false, 
      'category': 'Thực phẩm',
      'description': 'Thanh năng lượng cung cấp carbohydrate và chất điện giải cần thiết cho các hoạt động thể thao cường độ cao. Hương vị thơm ngon, dễ tiêu hóa.'
    },
  ];

  String _selectedCategory = 'Quần áo';
  String _selectedSort = 'Xem theo giá';
  RangeValues _priceRange = const RangeValues(0, 42000000);
  bool _isPriceFilterVisible = false;

  List<Map<String, dynamic>> get items {
    List<Map<String, dynamic>> filteredItems = List.from(_items);

    // Filter by Category
    if (_selectedCategory.isNotEmpty) {
      filteredItems = filteredItems.where((item) => item['category'] == _selectedCategory).toList();
    }

    // Filter by Price Range (Optional, but good to have consistent with UI)
    // filteredItems = filteredItems.where((item) {
    //   final price = item['price'] as num;
    //   return price >= _priceRange.start && price <= _priceRange.end;
    // }).toList();

    // Sort
    if (_selectedSort == 'Giá Thấp - Cao') {
      filteredItems.sort((a, b) => (a['price'] as num).compareTo(b['price'] as num));
    } else if (_selectedSort == 'Giá Cao - Thấp') {
      filteredItems.sort((a, b) => (b['price'] as num).compareTo(a['price'] as num));
    }

    return filteredItems;
  }

  String get selectedCategory => _selectedCategory;
  String get selectedSort => _selectedSort;
  RangeValues get priceRange => _priceRange;
  bool get isPriceFilterVisible => _isPriceFilterVisible;

  void setCategory(String category) {
    if (_selectedCategory == category) {
      _selectedCategory = '';
    } else {
      _selectedCategory = category;
    }
    notifyListeners();
  }

  void setSort(String sort) {
    _selectedSort = sort;
    if (sort == 'Xem theo giá') {
      _isPriceFilterVisible = !_isPriceFilterVisible;
    } else {
      _isPriceFilterVisible = false;
    }
    notifyListeners();
  }

  void setPriceRange(RangeValues range) {
    _priceRange = range;
    notifyListeners();
  }

  void toggleItemChecked(int id) {
    final item = _items.firstWhere((item) => item['id'] == id);
    item['checked'] = !item['checked'];
    notifyListeners();
  }

  void updateQuantity(int id, int quantity) {
    final item = _items.firstWhere((item) => item['id'] == id);
    if (quantity > 0) {
      item['quantity'] = quantity;
      notifyListeners();
    }
  }
  
  void toggleSelectAll(bool? value) {
    if (value == null) return;
    for (var item in _items) {
      item['checked'] = value;
    }
    notifyListeners();
  }

  bool get areAllItemsChecked => _items.every((item) => item['checked']);

  String get totalPrice {
    double total = 0;
    for (var item in _items) {
      if (item['checked']) {
        total += item['price'] * item['quantity'];
      }
    }
    // Format price
    return '${total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ';
  }
}
