// lib/services/session_lifecycle_service.dart
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:supabase_flutter/supabase_flutter.dart';

class SessionLifecycleService {
  static const String _keyLastPid = 'last_known_pid';

  /// Trả về TRUE nếu là Cold Start (Cần đăng xuất)
  /// Trả về FALSE nếu là Hot Restart (Giữ session)
  static Future<bool> checkIsColdStart() async {
    debugPrint("--- [SessionLifecycle] Bắt đầu kiểm tra ---");

    final prefs = await SharedPreferences.getInstance();
    final int currentPid = pid;
    final int? lastPid = prefs.getInt(_keyLastPid);

    bool isColdStart = false;

    // Logic kiểm tra
    if (lastPid != null && lastPid != currentPid) {
      debugPrint("--- [SessionLifecycle] => PHÁT HIỆN COLD START (PID đổi từ $lastPid sang $currentPid). Signing out to enforce logout on cold start.");
      // On cold start, clear Supabase session so users are logged out.
      try {
        await Supabase.instance.client.auth.signOut();
        debugPrint('--- [SessionLifecycle] Supabase signOut() completed.');
      } catch (e) {
        debugPrint('--- [SessionLifecycle] Supabase signOut() failed: ${e.toString()}');
      }
      isColdStart = true;
    } else {
      debugPrint("--- [SessionLifecycle] => Hot Restart hoặc lần đầu chạy (PID $currentPid). Giữ nguyên.");
      isColdStart = false;
    }

    // Luôn cập nhật PID mới nhất
    await prefs.setInt(_keyLastPid, currentPid);

    return isColdStart;
  }
}