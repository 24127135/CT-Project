import 'package:flutter/material.dart';
import 'trip_dashboard_1.dart';
import 'trip_dashboard_2.dart';
import 'trip_dashboard_note.dart';

const kBgColor = Color(0xFFF8F6F2);
const kPrimaryGreen = Color(0xFF38C148);

class TripDashboard3 extends StatefulWidget {
  const TripDashboard3({super.key});

  @override
  State<TripDashboard3> createState() => _TripDashboard3State();
}

class _TripDashboard3State extends State<TripDashboard3> {
  final List<String> _notes = [];

  void _navigateToNoteScreen() async {
    final newNote = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const TripDashboardNote()),
    );

    if (newNote != null && newNote.isNotEmpty) {
      setState(() {
        _notes.add(newNote);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: Column(
          children: [
            const _TripHeader(),
            const _TripTabs(activeIndex: 2),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(
                    bottom: 80, left: 24, right: 24),
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  final note = _notes[index];
                  return Dismissible(
                    key: Key(note + index.toString()), // Unique key for each item
                    direction: DismissDirection.endToStart, // Swipe from right to left
                    onDismissed: (direction) {
                      setState(() {
                        _notes.removeAt(index);
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("'$note' đã được xóa")),
                      );
                    },
                    background: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(right: 20.0),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        note,
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryGreen,
        onPressed: _navigateToNoteScreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
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
