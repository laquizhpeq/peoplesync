import 'package:flutter/material.dart';

class AppColorScheme {
  // Seed Color: Sapphire Blue (#3B82F6) - El ADN de la marca

  static const light = ColorScheme(
    brightness: Brightness.light,
    // Primary: Sapphire Blue
    primary: Color(0xFF2563EB),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFDBEAFE),
    onPrimaryContainer: Color(0xFF1E40AF),

    // Secondary: Cyan Glacial
    secondary: Color(0xFF06B6D4),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFCFFAFE),
    onSecondaryContainer: Color(0xFF0891B2),

    // Tertiary: Soft Indigo
    tertiary: Color(0xFF818CF8),
    onTertiary: Colors.white,

    // Neutral / Background
    error: Color(0xFFBA1A1A),
    onError: Colors.white,
    surface: Color(0xFFF1F5F9), // Slate White
    onSurface: Color(0xFF1A1A1A), // Deep Charcoal
    surfaceContainerHighest: Color(0xFFE2E8F0),
    onSurfaceVariant: Color(0xFF475569),
  );

  static const dark = ColorScheme(
    brightness: Brightness.dark,
    // Primary: Sky Blue (Suavizado para Dark Mode)
    primary: Color(0xFF60A5FA),
    onPrimary: Color(0xFF00318C),
    primaryContainer: Color(0xFF1E40AF),
    onPrimaryContainer: Color(0xFFDBEAFE),

    // Secondary: Electric Cyan
    secondary: Color(0xFF22D3EE),
    onSecondary: Color(0xFF00363D),
    secondaryContainer: Color(0xFF0891B2),
    onSecondaryContainer: Color(0xFFCFFAFE),

    // Tertiary: Lavender Mist
    tertiary: Color(0xFFA5B4FC),
    onTertiary: Color(0xFF2D3282),

    // Neutral / Background
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    surface: Color(0xFF0F172A), // Midnight Slate
    onSurface: Color(0xFFF8FAFC), // White Blue
    surfaceContainerHighest: Color(0xFF1E293B), // Para las tarjetas
    onSurfaceVariant: Color(0xFF94A3B8),
  );
}
