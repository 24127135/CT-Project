import 'package:flutter/material.dart';

class NotificationService {
  static final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void showSuccess(String message, {Duration duration = const Duration(milliseconds: 1200)}) {
    messengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
      duration: duration,
    ));
  }

  static void showError(String message, {Duration duration = const Duration(seconds: 3)}) {
    messengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: duration,
    ));
  }

  static void showInfo(String message, {Duration duration = const Duration(milliseconds: 1000)}) {
    messengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(message),
      duration: duration,
    ));
  }
}
