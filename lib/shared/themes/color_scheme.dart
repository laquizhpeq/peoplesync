import 'package:flutter/material.dart';

class AppColorScheme {
  static const light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFFE85D5D),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFFFD7CC),
    onPrimaryContainer: Color(0xFF6A1F1B),
    secondary: Color(0xFFFF8A65),
    onSecondary: Color(0xFF4A160C),
    secondaryContainer: Color(0xFFFFD8C4),
    onSecondaryContainer: Color(0xFF6A2815),
    tertiary: Color(0xFFF4B860),
    onTertiary: Color(0xFF4B2D00),
    error: Color(0xFFBA1A1A),
    onError: Colors.white,
    surface: Color(0xFFFFF6F1),
    onSurface: Color(0xFF2E1B17),
    surfaceContainerHighest: Color(0xFFFCE4DA),
    onSurfaceVariant: Color(0xFF7B5B55),
  );

  static const dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFFF8A80),
    onPrimary: Color(0xFF5C1414),
    primaryContainer: Color(0xFF8B3632),
    onPrimaryContainer: Color(0xFFFFDAD6),
    secondary: Color(0xFFFFB38A),
    onSecondary: Color(0xFF52200A),
    secondaryContainer: Color(0xFF6A341A),
    onSecondaryContainer: Color(0xFFFFDBC9),
    tertiary: Color(0xFFF5C877),
    onTertiary: Color(0xFF442C00),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    surface: Color(0xFF201513),
    onSurface: Color(0xFFF7E9E5),
    surfaceContainerHighest: Color(0xFF362320),
    onSurfaceVariant: Color(0xFFD7BBB4),
  );
}
