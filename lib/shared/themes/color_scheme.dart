import 'package:flutter/material.dart';

class AppColorScheme {
  static const light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF2E7D32),
    onPrimary: Colors.white,
    secondary: Color(0xFF81C784),
    onSecondary: Colors.black,
    error: Colors.red,
    onError: Colors.white,
    surface: Colors.white,
    onSurface: Colors.black,
  );

  static const dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF81C784),
    onPrimary: Colors.black,
    secondary: Color(0xFF2E7D32),
    onSecondary: Colors.white,
    error: Colors.red,
    onError: Colors.white,
    surface: Colors.black,
    onSurface: Colors.white,
  );
}
