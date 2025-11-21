import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/trip_provider.dart';
import 'tripinfopart3.dart'; // Ensure this import is correct for your project

class TripTimeScreen extends StatefulWidget {
  const TripTimeScreen({super.key});

  @override
  State<TripTimeScreen> createState() => _TripTimeScreenState();
}

class _TripTimeScreenState extends State<TripTimeScreen> {
  final Color primaryGreen = const Color(0xFF4CAF50);
  // Unused color removed or kept if needed:
  // final Color darkGreen = const Color(0xFF388E3C);

  // --- FIXED CALENDAR DIALOG FUNCTION ---
  Future<void> _selectDateRange(BuildContext context, TripProvider tripData) async {
    // 1. Get the screen width to make the dialog responsive
    final screenWidth = MediaQuery.of(context).size.width;
    
    // 2. Calculate a safe width for the dialog (Screen width minus padding)
    // We limit it to 400px max so it doesn't look weird on tablets/wide screens.
    final dialogWidth = screenWidth > 400 ? 400.0 : screenWidth - 48;

    final config = CalendarDatePicker2WithActionButtonsConfig(
      calendarType: CalendarDatePicker2Type.range,
      selectedDayHighlightColor: primaryGreen,
      
      // --- FIX: Slightly smaller fonts to prevent internal overflow on small screens ---
      controlsTextStyle: const TextStyle(
        color: Colors.black87,
        fontSize: 15, // Standard readable size
        fontWeight: FontWeight.bold,
      ),
      dayTextStyle: const TextStyle(
        color: Colors.black87, 
        fontSize: 13, // Slightly smaller to fit 7 days in a row comfortably
        fontWeight: FontWeight.bold
      ),
      weekdayLabelTextStyle: const TextStyle(
        color: Colors.black54,
        fontSize: 13, // Match day text size
        fontWeight: FontWeight.bold,
      ),
      
      // Custom Icons
      lastMonthIcon: const Icon(Icons.arrow_back_ios, size: 16, color: Colors.black87),
      nextMonthIcon: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black87),
      
      // Button Styles
      okButtonTextStyle: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
      cancelButtonTextStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
      
      // Visual tweaks
      dayBorderRadius: BorderRadius.circular(8),
    );

    final List<DateTime?>? results = await showCalendarDatePicker2Dialog(
      context: context,
      config: config,
      // --- KEY FIX: Use the calculated dynamic width ---
      dialogSize: Size(dialogWidth, 400), 
      borderRadius: BorderRadius.circular(15),
      value: (tripData.startDate != null && tripData.endDate != null)
          ? [tripData.startDate, tripData.endDate]
          : [],
    );

    if (results != null && results.length == 2 && results[0] != null && results[1] != null) {
      context.read<TripProvider>().setTripDates(results[0]!, results[1]!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripData = context.watch<TripProvider>();

    String dateText = 'MM/DD/YYYY';
    bool hasDate = tripData.startDate != null && tripData.endDate != null;

    if (hasDate) {
      String start = DateFormat('dd/MM/yyyy').format(tripData.startDate!);
      String end = DateFormat('dd/MM/yyyy').format(tripData.endDate!);
      dateText = '$start - $end';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Thông tin chuyến đi',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
            ),
            Text(
                'Bước 2/5',
                style: TextStyle(color: Colors.white70, fontSize: 14)
            ),
          ],
        ),
        backgroundColor: primaryGreen,
        elevation: 0,
      ),
      // --- SCROLLABLE BODY FIX ---
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                  'Thời gian chuyến đi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 16),

              // --- DATE PICKER TRIGGER ---
              GestureDetector(
                onTap: () => _selectDateRange(context, tripData),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: primaryGreen, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.black54),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          dateText,
                          style: TextStyle(
                            fontSize: 16,
                            color: hasDate ? Colors.black87 : Colors.black54,
                            fontWeight: hasDate ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.calendar_today, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              if (hasDate)
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                    'Tổng cộng: ${tripData.durationDays} ngày',
                    style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                  ),
                ),

              if (!hasDate)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Text(
                      '❗️ Vui lòng chọn ngày đi và về',
                      style: TextStyle(color: Colors.red.shade700, fontSize: 13)
                  ),
                ),
              
              // Added extra space at bottom for scrolling comfort
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (!hasDate) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Vui lòng chọn khoảng thời gian!'),
                            backgroundColor: Colors.red
                        )
                    );
                    return;
                  }
                  Navigator.push(
                      context,
                      // Ensure TripLevelScreen is imported properly
                      MaterialPageRoute(builder: (context) => const TripLevelScreen()) 
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                    'Tiếp theo',
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}