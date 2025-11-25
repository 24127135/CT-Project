import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/welcome_view.dart';
import 'screens/home_screen.dart';
import 'providers/trip_provider.dart';
import 'core/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

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
      // Thay vì gán cứng AuthGate(child: WelcomeView), ta để AuthGate tự quyết định
      home: const AuthGate(),
      routes: {
        '/welcome': (_) => const WelcomeView(),
        '/home': (_) => const HomePage(),
      },
    );
  }
}

/// AUTHGATE: Cổng kiểm soát đăng nhập
/// - Nếu có Session -> Vào thẳng HomePage
/// - Nếu chưa -> Vào WelcomeView
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      // Lắng nghe luồng sự kiện Auth của Supabase
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // 1. Trạng thái chờ: Đang tải dữ liệu (tránh màn hình trắng)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Lấy session hiện tại
        // Stream trả về AuthState, trong đó có chứa session
        final session = snapshot.data?.session;

        if (session != null) {
          // Đã đăng nhập -> Vào Home
          return const HomePage();
        } else {
          // Chưa đăng nhập (hoặc hết hạn) -> Vào Welcome/Login
          return const WelcomeView();
        }
      },
    );
  }
}