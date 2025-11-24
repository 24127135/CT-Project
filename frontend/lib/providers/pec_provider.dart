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
      'description': 'Áo khoác chống nước nhẹ, thoáng khí, thích hợp cho đi bộ đường dài và du lịch bụi. Có mũ trùm đầu có thể điều chỉnh và túi khóa kéo tiện lợi.',
      'weight': 300,
      'images': [
        'https://contents.mediadecathlon.com/p1744283/k\$f0b275c3207e208e12771a5c385d3ff8/sq/ao-khoac-chong-tham-nuoc-leo-nui-mh100-cho-nam-den.jpg',
        'https://contents.mediadecathlon.com/p1744284/k\$95e86a9787f73772b15242c71a36d753/sq/ao-khoac-chong-tham-nuoc-leo-nui-mh100-cho-nam-den.jpg',
        'https://contents.mediadecathlon.com/p1744285/k\$2e89656365a636536587456365874563/sq/ao-khoac-chong-tham-nuoc-leo-nui-mh100-cho-nam-den.jpg'
      ]
    },
    {
      'id': 2, 
      'name': 'Quần trekking', 
      'store': 'The North Face', 
      'price': 1500000, 
      'quantity': 2, 
      'checked': false, 
      'category': 'Quần áo',
      'description': 'Quần trekking co giãn 4 chiều, khô nhanh, chống thấm nước nhẹ. Thiết kế tiện dụng với nhiều túi và đai lưng có thể điều chỉnh.',
      'weight': 250,
      'images': [
        'https://images.thenorthface.com/is/image/TheNorthFace/NF0A5J4E_JK3_hero?wid=800&hei=800&fmt=jpeg&qlt=90&resMode=sharp2&op_usm=0.9,1.0,8,0',
        'https://images.thenorthface.com/is/image/TheNorthFace/NF0A5J4E_JK3_alt1?wid=800&hei=800&fmt=jpeg&qlt=90&resMode=sharp2&op_usm=0.9,1.0,8,0'
      ]
    },
    {
      'id': 3, 
      'name': 'Giày leo núi', 
      'store': 'Salomon', 
      'price': 2500000, 
      'quantity': 1, 
      'checked': true, 
      'category': 'Phụ kiện',
      'description': 'Giày leo núi bền bỉ, đế cao su chống trượt tốt trên mọi địa hình. Lớp lót êm ái giúp bảo vệ chân trong những chuyến đi dài.',
      'weight': 800,
      'images': [
        'https://www.salomon.com/sites/default/files/styles/product_600/public/content-images/product/L41285600_0_GHO.jpg',
        'https://www.salomon.com/sites/default/files/styles/product_600/public/content-images/product/L41285600_1_GHO.jpg'
      ]
    },
    {
      'id': 4, 
      'name': 'Balo 40L', 
      'store': 'Osprey', 
      'price': 3200000, 
      'quantity': 1, 
      'checked': false, 
      'category': 'Dụng cụ',
      'description': 'Balo du lịch 40L với hệ thống đệm lưng thoáng khí Anti-Gravity. Ngăn chứa rộng rãi, có ngăn riêng cho túi ngủ và áo mưa.',
      'weight': 1200,
      'images': [
        'https://www.osprey.com/images/product/hero/farpoint40_f22_black_hero.jpg',
        'https://www.osprey.com/images/product/detail/farpoint40_f22_black_detail1.jpg'
      ]
    },
    {
      'id': 5, 
      'name': 'Lều 2 người', 
      'store': 'Naturehike', 
      'price': 1800000, 
      'quantity': 1, 
      'checked': false, 
      'category': 'Dụng cụ',
      'description': 'Lều cắm trại 2 người siêu nhẹ, chống thấm nước PU3000mm. Khung nhôm chắc chắn, dễ dàng lắp đặt và tháo dỡ.',
      'weight': 1500,
      'images': [
        'https://naturehike.com.vn/wp-content/uploads/2019/07/leu-cam-trai-2-nguoi-naturehike-nh17t001-t-1.jpg',
        'https://naturehike.com.vn/wp-content/uploads/2019/07/leu-cam-trai-2-nguoi-naturehike-nh17t001-t-2.jpg'
      ]
    },
    {
      'id': 6, 
      'name': 'Thanh năng lượng', 
      'store': 'GU Energy', 
      'price': 50000, 
      'quantity': 5, 
      'checked': false, 
      'category': 'Thực phẩm',
      'description': 'Thanh năng lượng cung cấp carbohydrate và chất điện giải cần thiết cho các hoạt động thể thao cường độ cao. Hương vị thơm ngon, dễ tiêu hóa.',
      'weight': 50,
      'images': [
        'https://guenergy.com.vn/wp-content/uploads/2020/08/Chocolate-Outrage-1.jpg',
        'https://guenergy.com.vn/wp-content/uploads/2020/08/Chocolate-Outrage-2.jpg'
      ]
    },
  ];

  String _selectedCategory = 'Quần áo';
  String _selectedSort = 'Xem theo giá';
  String _searchQuery = '';
  RangeValues _priceRange = const RangeValues(0, 42000000);
  bool _isPriceFilterVisible = false;

  List<Map<String, dynamic>> get items {
    List<Map<String, dynamic>> filteredItems = List.from(_items);

    // Filter by Search Query
    if (_searchQuery.isNotEmpty) {
      filteredItems = filteredItems.where((item) => 
        item['name'].toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Filter by Category
    if (_selectedCategory.isNotEmpty) {
      filteredItems = filteredItems.where((item) => item['category'] == _selectedCategory).toList();
    }

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
  String get searchQuery => _searchQuery;
  RangeValues get priceRange => _priceRange;
  bool get isPriceFilterVisible => _isPriceFilterVisible;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void addItem(String name, String category, double price) {
    final newItem = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'name': name,
      'store': 'Cá nhân',
      'price': price,
      'quantity': 1,
      'checked': false,
      'category': category,
      'description': 'Vật dụng cá nhân thêm vào danh sách.',
      'weight': 0,
      'images': <String>[]
    };
    _items.add(newItem);
    notifyListeners();
  }

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
    if (item['checked']) {
      if (item['quantity'] == 0) item['quantity'] = 1;
    } else {
      item['quantity'] = 0;
    }
    notifyListeners();
  }

  void updateQuantity(int id, int quantity) {
    final item = _items.firstWhere((item) => item['id'] == id);
    if (quantity >= 0) {
      item['quantity'] = quantity;
      item['checked'] = quantity > 0;
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
    return '${total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ';
  }

  int get totalWeight {
    return _items.where((item) => item['checked']).fold(0, (sum, item) => sum + ((item['weight'] as int? ?? 0) * (item['quantity'] as int)));
  }
}
