import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// debugPrint is provided by Flutter material import; no separate foundation import needed
import 'screens/welcome_view.dart';
import 'screens/home_screen.dart';
import 'providers/trip_provider.dart';
import 'core/supabase_config.dart';
import 'services/session_lifecycle_service.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  // load API key first
  await dotenv.load(fileName: ".env");
  
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // Lấy kết quả xem có phải Cold Start không?
  // isColdStart = true nghĩa là vừa tắt app bật lại -> Phải về Welcome
  final bool isColdStart = await SessionLifecycleService.checkIsColdStart();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TripProvider()),
      ],
      // Truyền cờ isColdStart vào MyApp
      child: MyApp(isColdStart: isColdStart),
    ),
  );
}

class MyApp extends StatelessWidget {
  // Nhận biến từ main
  final bool isColdStart;

  const MyApp({super.key, required this.isColdStart});

  @override
  Widget build(BuildContext context) {
    // 1. Lấy session hiện tại (có thể vẫn còn cache trong RAM dù đã signOut)
    final session = Supabase.instance.client.auth.currentSession;

    debugPrint("--- [MyApp Check] ColdStart: $isColdStart | Session: ${session != null ? 'Có' : 'Không'} ---");

    // 2. LOGIC QUYẾT ĐỊNH MÀN HÌNH KHỞI ĐỘNG (QUAN TRỌNG)
    Widget startScreen;

    if (isColdStart) {
      // Nếu là Cold Start -> BẮT BUỘC về Welcome (kệ session nói gì)
      startScreen = const WelcomeView();
    } else if (session != null) {
      // Nếu không phải Cold Start (Hot restart) VÀ có session -> Vào Home
      startScreen = const HomePage();
    } else {
      // Còn lại -> Welcome
      startScreen = const WelcomeView();
    }

    return MaterialApp(
      title: 'Trek Guide',
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => const HomePage(),
        '/welcome': (context) => const WelcomeView(),
      },
      // Sử dụng màn hình đã quyết định ở trên
      home: startScreen,
    );
  }
}