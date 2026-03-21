import 'package:flutter/material.dart';

class AppTextTheme {
  // Configuración para Modo Claro
  static const light = TextTheme(
    // Headline / Nombre del contacto
    titleLarge: TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Color(0xFF1A1A1A), // Deep Charcoal
      letterSpacing: -0.5, // Toque moderno
    ),
    // Body / Teléfonos, correos, notas
    bodyMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Color(0xFF475569), // Slate Grey (Suave para la vista)
    ),
    // Label / Rótulos de categoría (MÓVIL, CASA, TRABAJO)
    labelSmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
      color: Color(0xFF06B6D4), // Usamos el Secondary (Cyan) como acento
    ),
  );

  // Configuración para Modo Oscuro
  static const dark = TextTheme(
    titleLarge: TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Color(0xFFF8FAFC), // White Blue
      letterSpacing: -0.5,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Color(0xFF94A3B8), // Slate Grey claro
    ),
    labelSmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.5, // Un poco más de aire en dark mode
      color: Color(0xFF22D3EE), // Electric Cyan (Más brillante)
    ),
  );
}
