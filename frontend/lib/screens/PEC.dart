import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/providers/trip_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:frontend/screens/trip_dashboard.dart';

class PECScreen extends StatelessWidget {
  final int? planId;

  const PECScreen({super.key, this.planId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      body: SafeArea(
        child: PECContent(planId: planId),
      ),
    );
  }
}

class PECContent extends StatefulWidget {
  final int? planId;
  const PECContent({super.key, this.planId});

  @override
  State<PECContent> createState() => _PECContentState();
}

// ----------------- MODEL -----------------

class _EquipmentItem {
  final String id;
  final String name;
  final String category;
  final double price;
  final String imageUrl;
  final int weightGrams;
  final String? buyLink; // NEW FIELD
  bool selected;
  int quantity;
  String? aiReason;
  

  _EquipmentItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.weightGrams,
    this.buyLink,
    this.selected = false,
    this.quantity = 1,
    this.aiReason,
  });

  factory _EquipmentItem.fromMap(Map<String, dynamic> map) {
    return _EquipmentItem(
      id: map['id'].toString(), // Force String for safe comparison
      name: map['name'] as String? ?? 'Unknown Item',
      category: map['category'] as String? ?? 'Other',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['image_url'] as String? ?? '',
      weightGrams: map['weight_grams'] as int? ?? 0,
      buyLink: map['buy_link'] as String?, // Map from DB
    );
  }
}

enum _SortOption { none, lowToHigh, highToLow }

// ----------------- STATE -----------------

class _PECContentState extends State<PECContent> {
  final Color _primaryGreen = const Color(0xFF4CD964);
  final Color _textBlack = const Color(0xFF1D1D1D);
  final Color _textGray = const Color(0xFF8E8E93);
  final Color _priceRed = const Color(0xFFE02020);
  final Color _bgGray = const Color(0xFFF2F2F7);

  late Future<void> _initialLoadFuture;
  List<_EquipmentItem> _allEquipment = [];
  
  final List<String> _categories = <String>[
    'Quần áo', 'Phụ kiện', 'Dụng cụ', 'Thực phẩm',
  ];
  
  int _currentCategoryIndex = 0; 
  _SortOption _sortOption = _SortOption.none;
  
  double _maxPriceLimit = 20000000; 
  RangeValues _currentPriceRange = const RangeValues(0, 20000000);

  @override
  void initState() {
    super.initState();
    _initialLoadFuture = _loadData();
  }

  // Click an equipment to direct to shop website
  Future<void> _launchBuyLink(String itemName, String? dbLink) async {
    final Uri url;

    if (dbLink != null && dbLink.isNotEmpty) {
      // 1. Priority: Use the specific link from Database
      url = Uri.parse(dbLink);
    } else {
      // 2. Fallback: Generate a Shopee Vietnam Search URL
      // You can swap this for 'lazada.vn/catalog/?q=' or Google Shopping
      final query = Uri.encodeComponent(itemName);
      url = Uri.parse('https://shopee.vn/search?keyword=$query');
    }

    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint("Error launching URL: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không thể mở liên kết mua hàng")),
        );
      }
    }
  }

  // --- CORE LOGIC: Fetch Catalog + Plan Data & Merge ---
  Future<void> _loadData() async {
    try {
      final client = Supabase.instance.client;

      // 1. GET PLAN ID
      int? effectivePlanId = widget.planId;
      if (effectivePlanId == null) {
        try {
          // Listen: false is important here to avoid rebuild loops
          final tripProvider = Provider.of<TripProvider>(context, listen: false);
          effectivePlanId = tripProvider.currentPlanId;
        } catch (e) {
          debugPrint("⚠️ [PEC] Provider lookup failed: $e");
        }
      }

      debugPrint("🔍 [PEC] Fetching data for Plan ID: $effectivePlanId");

      if (effectivePlanId == null) {
        debugPrint("❌ [PEC] Error: No Plan ID found. Aborting.");
        return;
      }

      // 2. FETCH EQUIPMENT CATALOG (The DB Items)
      final equipResponse = await client.from('equipment').select();
      final List<_EquipmentItem> loadedItems = (equipResponse as List)
          .map<_EquipmentItem>((item) => _EquipmentItem.fromMap(item))
          .toList();
      
      debugPrint("🔍 [PEC] Database has ${loadedItems.length} items.");

      // 3. FETCH PLAN (The AI Recommendations)
      final planResponse = await client
          .from('plans')
          .select('personalized_equipment_list')
          .eq('id', effectivePlanId)
          .maybeSingle();
      
      Map<String, dynamic> aiRecommendations = {};
      
      if (planResponse != null && planResponse['personalized_equipment_list'] != null) {
        aiRecommendations = Map<String, dynamic>.from(planResponse['personalized_equipment_list']);
        debugPrint("🔍 [PEC] Found AI Data for Categories: ${aiRecommendations.keys.toList()}");
      } else {
        debugPrint("⚠️ [PEC] No AI checklist found in DB for this plan.");
      }

      // 4. MATCHING LOGIC
      int matchCount = 0;
      if (aiRecommendations.isNotEmpty) {
        for (var item in loadedItems) {
          // Check this item against all AI categories
          aiRecommendations.forEach((category, list) {
            if (list is List) {
              for (var rec in list) {
                // FORCE STRING COMPARISON for safety
                String recId = rec['id'].toString();
                String itemId = item.id;

                if (recId == itemId) {
                  item.selected = false; // Requirement: Don't check by default
                  item.quantity = (rec['quantity'] as num?)?.toInt() ?? 1;
                  item.aiReason = rec['reason'] as String?; 
                  matchCount++;
                }
              }
            }
          });
        }
      }
      
      debugPrint("🔍 [PEC] Success! Matched $matchCount items from AI with Database.");

      if (mounted) {
        setState(() {
          _allEquipment = loadedItems;
          // Dynamically set price range based on actual data
          if (loadedItems.isNotEmpty) {
            double maxP = loadedItems.map((e) => e.price).fold(0.0, max);
            _maxPriceLimit = maxP == 0 ? 5000000 : maxP;
            _currentPriceRange = RangeValues(0, _maxPriceLimit);
          }
        });
      }
    } catch (e) {
      debugPrint('❌ [PEC] CRITICAL ERROR: $e');
    }
  }

  // Calculate total for SELECTED items
  double get _totalMoney => _allEquipment.fold(0, (sum, e) => e.selected ? sum + (e.price * e.quantity) : sum);

  bool get _isAllSelected {
    final visible = _visibleItems;
    if (visible.isEmpty) return false;
    return visible.every((e) => e.selected);
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      for (var item in _visibleItems) {
        item.selected = value ?? false;
      }
    });
  }

  // --- FILTERING LOGIC ---
  List<_EquipmentItem> get _visibleItems {
    if (_allEquipment.isEmpty) return [];
    final String currentCat = _categories[_currentCategoryIndex];
    
    // Normalize string for better matching
    String normalize(String s) => s.toLowerCase().trim();

    List<_EquipmentItem> filtered = _allEquipment.where((e) {
      // 1. STRICT FILTER: Only show items AI recommended
      if (e.aiReason == null) return false;

      // 2. CATEGORY FILTER (Soft Match)
      bool catMatch = false;
      String dbCat = normalize(e.category);
      
      if (currentCat == 'Quần áo') {
        catMatch = dbCat.contains('quần') || dbCat.contains('áo') || dbCat.contains('clothes');
      } else if (currentCat == 'Phụ kiện') {
        catMatch = dbCat.contains('phụ kiện') || dbCat.contains('accessory') || dbCat.contains('mũ') || dbCat.contains('kính');
      } else if (currentCat == 'Dụng cụ') {
        catMatch = dbCat.contains('dụng cụ') || dbCat.contains('gear') || dbCat.contains('tool') || dbCat.contains('balo') || dbCat.contains('lều') || dbCat.contains('trại');
      } else if (currentCat == 'Thực phẩm') {
        catMatch = dbCat.contains('thực phẩm') || dbCat.contains('food') || dbCat.contains('nước') || dbCat.contains('ăn');
      } else {
        catMatch = true; 
      }

      // 3. PRICE FILTER
      bool priceMatch = e.price >= _currentPriceRange.start && e.price <= _currentPriceRange.end;

      return catMatch && priceMatch;
    }).toList();

    // SORTING
    if (_sortOption == _SortOption.lowToHigh) {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortOption == _SortOption.highToLow) {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    }

    return filtered;
  }
  
  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(value);
  }

  Future<void> _confirmChecklist() async {
    int? effectivePlanId = widget.planId ?? Provider.of<TripProvider>(context, listen: false).currentPlanId;
    if (effectivePlanId == null) return;

    Map<String, List<Map<String, dynamic>>> finalChecklist = {};

    // Group items by category for saving
    for (var item in _allEquipment.where((e) => e.selected)) {
      String catKey = item.category; 
      if (!finalChecklist.containsKey(catKey)) {
        finalChecklist[catKey] = [];
      }
      
      finalChecklist[catKey]!.add({
        "id": int.tryParse(item.id) ?? item.id,
        "name": item.name,
        "quantity": item.quantity,
        "price": item.price,
        "reason": item.aiReason 
      });
    }

    try {
      await Supabase.instance.client
          .from('plans')
          .update({'personalized_equipment_list': finalChecklist})
          .eq('id', effectivePlanId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Đã lưu danh sách trang bị!"),
          backgroundColor: Colors.green,
        ));

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const TripDashboard()),
          (Route<dynamic> route) => route.isFirst, // Go back to Home first or keep stack clean
        );
      }
    } catch (e) {
      debugPrint("Error saving checklist: $e");
    }
  }

  // ----------------- UI BUILDER -----------------

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        const SizedBox(height: 10),
        _buildCategoryList(),
        const SizedBox(height: 12),
        _buildFilterBar(),
        const SizedBox(height: 10),
        Expanded(
          child: FutureBuilder(
            future: _initialLoadFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else {
                return _buildProductList();
              }
            }
          ),
        ),
        _buildBottomBar(),
      ],
    );
  }

  // 1. HEADER
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Danh sách đồ dùng',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ),
          const SizedBox(width: 40), 
        ],
      ),
    );
  }

  // 2. CATEGORY TABS
  Widget _buildCategoryList() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = index == _currentCategoryIndex;
          return GestureDetector(
            onTap: () => setState(() => _currentCategoryIndex = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : _bgGray,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                _categories[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 3. FILTER BAR
  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Price Filter
          GestureDetector(
            onTap: _showPriceFilterModal,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _primaryGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Lọc giá',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // Sort Options
          _buildSortChip('Thấp - Cao', _SortOption.lowToHigh),
          const SizedBox(width: 8),
          _buildSortChip('Cao - Thấp', _SortOption.highToLow),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, _SortOption option) {
    final isSelected = _sortOption == option;
    return GestureDetector(
      onTap: () => setState(() => _sortOption = isSelected ? _SortOption.none : option),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _primaryGreen.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? _primaryGreen : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? _primaryGreen : _textGray,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // 4. PRODUCT LIST
  Widget _buildProductList() {
    final items = _visibleItems;
    
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text(
              "Chưa có đề xuất trong mục này.\n(Kiểm tra tab khác hoặc Logs)",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))
            ],
          ),
          child: Column(
            children: [
              // ---------------------------------------------------------
              // 👇 REPLACE THE OLD ROW WITH THIS NEW ROW 👇
              // ---------------------------------------------------------
              Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Align top for better layout
                children: [
                  // 1. Checkbox
                  Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: item.selected,
                      activeColor: _primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (val) {
                         setState(() => item.selected = val!);
                      },
                    ),
                  ),
                  
                  // 2. Image
                  Container(
                    width: 70,
                    height: 70,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade100,
                    ),
                    child: item.imageUrl.isNotEmpty
                        ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(item.imageUrl, fit: BoxFit.cover))
                        : const Center(child: Icon(Icons.image, color: Colors.grey)),
                  ),

                  // 3. Text Info (Expanded)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textBlack)),
                        const SizedBox(height: 4),
                        Text(
                          item.category, 
                          style: TextStyle(fontSize: 12, color: _textGray)
                        ),
                        const SizedBox(height: 4),
                        Text(_formatCurrency(item.price), style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _priceRed)),
                      ],
                    ),
                  ),

                  // 4. Quantity & Buy Button Column (NEW PART)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end, // Align to right side
                    children: [
                      // Quantity Row
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () => setState(() { if(item.quantity > 1) item.quantity--; }),
                            child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.remove, size: 20)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          InkWell(
                            onTap: () => setState(() => item.quantity++),
                            child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.add, size: 20)),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12), // Spacing between Qty and Button

                      // 🟢 "Buy Now" Button
                      InkWell(
                        onTap: () => _launchBuyLink(item.name, item.buyLink),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.withOpacity(0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.shopping_cart_outlined, size: 14, color: Colors.deepOrange),
                              const SizedBox(width: 4),
                              Text(
                                "Mua ngay", 
                                style: TextStyle(fontSize: 11, color: Colors.deepOrange, fontWeight: FontWeight.bold)
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              // ---------------------------------------------------------
              // 👆 END OF NEW ROW 👆
              // ---------------------------------------------------------
              
              if (item.aiReason != null)
                Container(
                  margin: const EdgeInsets.only(top: 8, left: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.auto_awesome, size: 14, color: Colors.orange),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.aiReason!,
                          style: TextStyle(fontSize: 13, color: Colors.orange.shade900, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                )
            ],
          ),
        );
      },
    );
  }

  // 5. BOTTOM BAR
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          // Select All
          GestureDetector(
            onTap: () => _toggleSelectAll(!_isAllSelected),
            child: Row(
              children: [
                Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: _isAllSelected,
                    activeColor: _primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) => _toggleSelectAll(val),
                  ),
                ),
                const Text("Tất cả", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Spacer(),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Tổng chi phí", style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text(_formatCurrency(_totalMoney), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _priceRed)),
            ],
          ),
          const SizedBox(width: 12),

          ElevatedButton(
            onPressed: _confirmChecklist,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 0,
            ),
            child: const Text("Xác nhận", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
    );
  }

  // 6. PRICE FILTER MODAL
  void _showPriceFilterModal() {
    RangeValues tempRange = _currentPriceRange;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Khoảng giá", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _priceBox(_formatCurrency(tempRange.start)),
                    const Text("-", style: TextStyle(fontSize: 20, color: Colors.grey)),
                    _priceBox(_formatCurrency(tempRange.end)),
                  ],
                ),
                const SizedBox(height: 20),
                RangeSlider(
                  values: tempRange,
                  min: 0,
                  max: _maxPriceLimit,
                  divisions: 20,
                  activeColor: _primaryGreen,
                  inactiveColor: Colors.grey.shade200,
                  onChanged: (values) {
                    setModalState(() => tempRange = values);
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text("Đóng", style: TextStyle(color: Colors.black)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => _currentPriceRange = tempRange);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        child: const Text("Áp dụng", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _priceBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _bgGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}