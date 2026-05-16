import 'package:flutter/material.dart';

class AppFeedbackService {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showInfo(String message) {
    _showSnackBar(message, backgroundColor: const Color(0xFF455A64));
  }

  static void showWarning(String message) {
    _showSnackBar(message, backgroundColor: const Color(0xFFEF6C00));
  }

  static void showError(String message) {
    _showSnackBar(message, backgroundColor: const Color(0xFFC62828));
  }

  static void _showSnackBar(String message, {required Color backgroundColor}) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
