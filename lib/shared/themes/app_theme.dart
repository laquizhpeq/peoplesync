import 'package:flutter/material.dart';
import 'button_theme.dart';
import 'color_scheme.dart';
import 'text_theme.dart';

class AppTheme {
  static const double _borderRadius = 22.0;

  static InputDecorationTheme _getInputTheme(
    ColorScheme colors,
    TextTheme text,
  ) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: BorderSide(
          color: colors.onSurfaceVariant.withValues(alpha: 0.18),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: BorderSide(color: colors.primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: BorderSide(color: colors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: BorderSide(color: colors.error, width: 1.2),
      ),
      hintStyle: text.bodyMedium?.copyWith(
        color: colors.onSurfaceVariant.withValues(alpha: 0.8),
      ),
      labelStyle: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
      floatingLabelStyle: text.bodyMedium?.copyWith(
        color: colors.primary,
        fontWeight: FontWeight.w700,
      ),
      prefixIconColor: colors.onSurfaceVariant,
      suffixIconColor: colors.onSurfaceVariant,
    );
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: AppColorScheme.light,
    textTheme: AppTextTheme.light,
    scaffoldBackgroundColor: const Color(0xFFFFF5F0),
    inputDecorationTheme: _getInputTheme(
      AppColorScheme.light,
      AppTextTheme.light,
    ),
    elevatedButtonTheme: AppButtonTheme.getElevatedButtonTheme(
      AppColorScheme.light,
    ),
    outlinedButtonTheme: AppButtonTheme.getOutlinedButtonTheme(
      AppColorScheme.light,
    ),
    textButtonTheme: AppButtonTheme.getTextButtonTheme(AppColorScheme.light),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColorScheme.light.onSurface,
      contentTextStyle: AppTextTheme.light.bodyMedium?.copyWith(
        color: AppColorScheme.light.surface,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      behavior: SnackBarBehavior.floating,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: AppColorScheme.dark,
    textTheme: AppTextTheme.dark,
    scaffoldBackgroundColor: const Color(0xFF140E10),
    inputDecorationTheme: _getInputTheme(
      AppColorScheme.dark,
      AppTextTheme.dark,
    ),
    elevatedButtonTheme: AppButtonTheme.getElevatedButtonTheme(
      AppColorScheme.dark,
    ),
    outlinedButtonTheme: AppButtonTheme.getOutlinedButtonTheme(
      AppColorScheme.dark,
    ),
    textButtonTheme: AppButtonTheme.getTextButtonTheme(AppColorScheme.dark),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColorScheme.dark.surfaceContainerHighest,
      contentTextStyle: AppTextTheme.dark.bodyMedium?.copyWith(
        color: AppColorScheme.dark.onSurface,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
