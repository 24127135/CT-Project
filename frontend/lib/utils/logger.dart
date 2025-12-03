import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppLogger {
  /// Enabled if `--dart-define=ENABLE_DEBUG_LOGS=true` or `.env` contains ENABLE_DEBUG_LOGS=true
  static bool get enabled {
    const fromDefine = bool.fromEnvironment('ENABLE_DEBUG_LOGS', defaultValue: false);
    if (fromDefine) return true;
    final env = dotenv.env['ENABLE_DEBUG_LOGS'];
    if (env != null) {
      final e = env.toLowerCase();
      return e == 'true' || e == '1';
    }
    return false;
  }

  static void d(String tag, String message) {
    if (!enabled) return;
    debugPrint('[$tag] $message');
  }

  static void e(String tag, String message) {
    if (!enabled) return;
    debugPrint('[ERROR][$tag] $message');
  }
}
