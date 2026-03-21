import 'package:flutter/material.dart';
import 'color_scheme.dart';
import 'text_theme.dart';
import 'button_theme.dart';

class AppTheme {
  static const double _borderRadius = 16.0;

  static InputDecorationTheme _getInputTheme(
    ColorScheme colors,
    TextTheme text,
  ) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: BorderSide(
          color: colors.onSurfaceVariant.withValues(alpha: 0.2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: BorderSide(color: colors.error, width: 1),
      ),
      labelStyle: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
      floatingLabelStyle: text.bodyMedium?.copyWith(
        color: colors.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: AppColorScheme.light,
    textTheme: AppTextTheme.light,
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
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: AppColorScheme.dark,
    textTheme: AppTextTheme.dark,
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
  );
}
