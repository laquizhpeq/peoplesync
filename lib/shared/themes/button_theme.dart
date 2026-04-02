import 'package:flutter/material.dart';

class AppButtonTheme {
  static const double _borderRadius = 18.0;

  static ButtonStyle _getCommonStyle() {
    return ElevatedButton.styleFrom(
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        fontFamily: 'Roboto',
      ),
    );
  }

  static ElevatedButtonThemeData getElevatedButtonTheme(
    ColorScheme colorScheme,
  ) {
    return ElevatedButtonThemeData(
      style: _getCommonStyle().copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurface.withValues(alpha: 0.12);
          }
          return colorScheme.primary;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurface.withValues(alpha: 0.38);
          }
          return colorScheme.onPrimary;
        }),
        overlayColor: WidgetStatePropertyAll(
          colorScheme.onPrimary.withValues(alpha: 0.08),
        ),
        shadowColor: WidgetStatePropertyAll(
          colorScheme.primary.withValues(alpha: 0.24),
        ),
        elevation: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) return 0;
          return 6;
        }),
      ),
    );
  }

  static OutlinedButtonThemeData getOutlinedButtonTheme(
    ColorScheme colorScheme,
  ) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: BorderSide(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.28),
          width: 1.2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        foregroundColor: colorScheme.onSurface,
        textStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: colorScheme.surface.withValues(alpha: 0.9),
      ),
    );
  }

  static TextButtonThemeData getTextButtonTheme(ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
