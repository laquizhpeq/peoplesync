import 'package:flutter/material.dart';

class AppTextTheme {
  static const light = TextTheme(
    titleLarge: TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Color(0xFF1A1A1A),
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 16,
      color: Color(0xFF475569),
    ),
  );

  static const dark = TextTheme(
    titleLarge: TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Color(0xFFF8FAFC),
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 16,
      color: Color(0xFF94A3B8),
    ),
  );
}
