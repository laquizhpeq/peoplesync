import 'package:flutter/foundation.dart';

enum AppLogLevel { debug, info, warning, error }

class AppLogger {
  static void debug(String message, {String scope = 'app'}) {
    _log(AppLogLevel.debug, message, scope: scope);
  }

  static void info(String message, {String scope = 'app'}) {
    _log(AppLogLevel.info, message, scope: scope);
  }

  static void warning(String message, {String scope = 'app'}) {
    _log(AppLogLevel.warning, message, scope: scope);
  }

  static void error(
    String message, {
    String scope = 'app',
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      AppLogLevel.error,
      message,
      scope: scope,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void _log(
    AppLogLevel level,
    String message, {
    required String scope,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final prefix = '[${level.name.toUpperCase()}][$scope][$timestamp]';
    debugPrint('$prefix $message');

    if (error != null) {
      debugPrint('$prefix error=$error');
    }
    if (stackTrace != null) {
      debugPrint('$prefix stackTrace=$stackTrace');
    }
  }
}
