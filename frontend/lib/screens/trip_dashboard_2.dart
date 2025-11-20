import 'package:flutter/material.dart';
import 'trip_dashboard_1.dart';
import 'trip_dashboard_3.dart';

const kBgColor = Color(0xFFF8F6F2);
const kPrimaryGreen = Color(0xFF38C148);

class TripDashboard2 extends StatefulWidget {
  const TripDashboard2({super.key});

  @override
  State<TripDashboard2> createState() => _TripDashboard2State();
}

class _TripDashboard2State extends State<TripDashboard2> {
  final List<ItemData> items = List.generate(
    6,
        (index) => ItemData(
      name: 'Tên vật dụng',
      shop: 'Tên cửa hàng',
      priceText: 'xx.xxx.xxx đ',
      quantity: 1,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: Column(
          children: [
            const _TripHeader(),
            const _TripTabs(activeIndex: 1),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _ItemCard(
                    data: items[index],
                    onIncrease: () {
                      setState(() {
                        items[index].quantity++;
                      });
                    },
                    onDecrease: () {
                      setState(() {
                        if (items[index].quantity > 0) {
                          items[index].quantity--;
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemData {
  final String name;
  final String shop;
  final String priceText;
  int quantity;

  ItemData({
    required this.name,
    required this.shop,
    required this.priceText,
    this.quantity = 1,
  });
}

class _TripHeader extends StatelessWidget {
  const _TripHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 12),
      child: Column(
        children: [
          const SizedBox(height: 4),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.black,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Bảng thông tin',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ],
      ),
    );
  }
}

class _TripTabs extends StatelessWidget {
  final int activeIndex;
  const _TripTabs({required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    Widget buildTab(String label, int index) {
      final bool isActive = index == activeIndex;
      return Expanded(
        child: GestureDetector(
          onTap: () {
            if (index == activeIndex) return;
            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const TripDashboard1(),
                ),
              );
            } else if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const TripDashboard2(),
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const TripDashboard3(),
                ),
              );
            }
          },
          child: Container(
            height: 44,
            margin: EdgeInsets.only(
              left: index == 0 ? 24 : 4,
              right: index == 2 ? 24 : 4,
            ),
            decoration: BoxDecoration(
              color: isActive ? kPrimaryGreen : const Color(0xFFE5E1DB),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        buildTab('Lộ trình', 0),
        buildTab('Vật dụng', 1),
        buildTab('Ghi chú', 2),
      ],
    );
  }
}

class _ItemCard extends StatelessWidget {
  final ItemData data;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _ItemCard({
    required this.data,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE9FBE4),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Text(
              'PNG',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.shop,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.priceText,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: onIncrease,
                icon: const Icon(Icons.add),
              ),
              Text(
                data.quantity.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: onDecrease,
                icon: const Icon(Icons.remove),
              ),
            ],
          )
        ],
      ),
    );
  }
}
