import 'package:flutter/material.dart';
import 'package:peoplesync/core/services/app_error_mapper.dart';

class AppFeedbackService {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  static String? _lastMessage;
  static DateTime? _lastShownAt;

  static void showInfo(String message) {
    _showSnackBar(message, backgroundColor: const Color(0xFF455A64));
  }

  static void showWarning(String message) {
    _showSnackBar(message, backgroundColor: const Color(0xFFEF6C00));
  }

  static void showError(String message) {
    _showSnackBar(message, backgroundColor: const Color(0xFFC62828));
  }

  static void showException(
    Object error, {
    String fallbackMessage =
        'Ha ocurrido un problema. Vuelve a intentarlo en unos segundos.',
  }) {
    showError(AppErrorMapper.toUserMessage(error, fallback: fallbackMessage));
  }

  static void _showSnackBar(String message, {required Color backgroundColor}) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) return;
    final now = DateTime.now();
    if (_lastMessage == message &&
        _lastShownAt != null &&
        now.difference(_lastShownAt!) < const Duration(seconds: 3)) {
      return;
    }
    _lastMessage = message;
    _lastShownAt = now;

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
