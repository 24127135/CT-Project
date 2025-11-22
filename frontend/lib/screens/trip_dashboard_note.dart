import 'package:flutter/material.dart';

class TripDashboardNote extends StatefulWidget {
  const TripDashboardNote({super.key});

  @override
  State<TripDashboardNote> createState() => _TripDashboardNoteState();
}

class _TripDashboardNoteState extends State<TripDashboardNote> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF8F6F2);
    const toolbarGrey = Color(0xFFE2E2E2);
    const primaryBlue = Color(0xFF007AFF);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            // ====== HEADER ======
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  const CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.black,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: toolbarGrey,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.ios_share_rounded, size: 20),
                        SizedBox(width: 10),
                        Icon(Icons.more_horiz, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ====== TEXT EDITING AREA ======
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  maxLines: null, // Allows for multiline input
                  expands: true,
                  style: const TextStyle(fontSize: 18),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Nhập ghi chú của bạn...',
                  ),
                ),
              ),
            ),

            // ====== BOTTOM TOOLBAR + NÚT TICK ======
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: toolbarGrey,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.grid_view_rounded),
                        SizedBox(width: 22),
                        Icon(Icons.attach_file_rounded),
                        SizedBox(width: 22),
                        Icon(Icons.edit_rounded),
                      ],
                    ),
                  ),
                  const Spacer(),
                  FloatingActionButton(
                    onPressed: () {
                      // Pass the note back to the previous screen
                      Navigator.of(context).pop(_controller.text);
                    },
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                    child: const Icon(Icons.check_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
