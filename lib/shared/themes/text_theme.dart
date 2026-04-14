import 'package:flutter/material.dart';

class AppTextTheme {
  static const light = TextTheme(
    displaySmall: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 38,
      fontWeight: FontWeight.w700,
      height: 1.05,
      color: Color(0xFF1E1B1A),
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 30,
      fontWeight: FontWeight.w700,
      height: 1.1,
      color: Color(0xFF1E1B1A),
    ),
    titleLarge: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: Color(0xFF1E1B1A),
    ),
    titleMedium: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: Color(0xFF332826),
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 16,
      height: 1.45,
      color: Color(0xFF5E504D),
    ),
    bodySmall: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 13,
      height: 1.35,
      color: Color(0xFF7A6B68),
    ),
    labelLarge: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 15,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
      color: Colors.white,
    ),
  );

  static const dark = TextTheme(
    displaySmall: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 38,
      fontWeight: FontWeight.w700,
      height: 1.05,
      color: Color(0xFFF8EAE5),
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 30,
      fontWeight: FontWeight.w700,
      height: 1.1,
      color: Color(0xFFF8EAE5),
    ),
    titleLarge: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: Color(0xFFF8EAE5),
    ),
    titleMedium: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: Color(0xFFE5D0CB),
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 16,
      height: 1.45,
      color: Color(0xFFCBB5B0),
    ),
    bodySmall: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 13,
      height: 1.35,
      color: Color(0xFFB89F9A),
    ),
    labelLarge: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 15,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
      color: Color(0xFF2E1B17),
    ),
  );
}
