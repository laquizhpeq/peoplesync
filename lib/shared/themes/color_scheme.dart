import 'package:flutter/material.dart';

class AppColorScheme {
  static const light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFFE83E6C),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFFFD6E3),
    onPrimaryContainer: Color(0xFF400015),
    secondary: Color(0xFFF2994A),
    onSecondary: Color(0xFF3D1500),
    secondaryContainer: Color(0xFFFFE4C4),
    onSecondaryContainer: Color(0xFF4C1800),
    tertiary: Color(0xFFFF8A65),
    onTertiary: Colors.white,
    error: Color(0xFFBA1A1A),
    onError: Colors.white,
    surface: Color(0xFFFFFAF8),
    onSurface: Color(0xFF1E1B1A),
    surfaceContainerHighest: Color(0xFFF2E5E0),
    onSurfaceVariant: Color(0xFF5E504D),
  );

  static const dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFFFB0C4),
    onPrimary: Color(0xFF58002B),
    primaryContainer: Color(0xFF7A1040),
    onPrimaryContainer: Color(0xFFFFD6E3),
    secondary: Color(0xFFFFCB8E),
    onSecondary: Color(0xFF3D1500),
    secondaryContainer: Color(0xFF5C2D0E),
    onSecondaryContainer: Color(0xFFFFE4C4),
    tertiary: Color(0xFFFFAB91),
    onTertiary: Color(0xFF3E1500),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    surface: Color(0xFF1A1215),
    onSurface: Color(0xFFF8EAE5),
    surfaceContainerHighest: Color(0xFF2D2022),
    onSurfaceVariant: Color(0xFFCBB5B0),
  );
}
