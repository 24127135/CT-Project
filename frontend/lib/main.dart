import 'package:flutter/material.dart';
import 'screens/trip_info_screen.dart'; // <-- Đã import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trek Guide',
      // ...
      home: const TripInfoScreen(), // <-- Đã đặt làm home
    );
  }
}