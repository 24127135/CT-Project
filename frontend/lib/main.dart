import 'package:flutter/material.dart';
import 'screens/welcome_view.dart';
import 'screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'providers/trip_provider.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/supabase_config.dart';
import 'dart:async';
// import 'package:your_app_name/core/app.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TripProvider('')),
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
      home: AuthGate(child: const WelcomeView()),
      routes: {
        '/welcome': (_) => const WelcomeView(),
        '/home': (_) => const HomePage(),
      },
    );
  }
}

class AuthGate extends StatefulWidget {
  final Widget child;
  const AuthGate({required this.child, super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Session? _session;
  late final StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    _session = Supabase.instance.client.auth.currentSession;
    // Listen for auth state changes
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      final session = (event as dynamic).session as Session?;
      setState(() => _session = session);
      // Use post frame callback to ensure Navigator is available
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (session != null) {
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          Navigator.of(context).pushReplacementNamed('/welcome');
        }
      });
    });
    // Ensure initial navigation reflects current session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_session != null) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/welcome');
      }
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_session != null) {
      return const HomePage();
    }
    return widget.child;
  }
}