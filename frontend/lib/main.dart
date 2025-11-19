import 'package:flutter/material.dart';
import 'features/home/screen/home_view.dart';
import 'package:provider/provider.dart';
import 'providers/trip_provider.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TripProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trek Guide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF425E3C),
          primary: const Color(0xFF425E3C),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F6F2),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const HomeView(),
    );
  }
}