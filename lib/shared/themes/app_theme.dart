import 'package:flutter/material.dart';
// Asegúrate de que estas rutas sean las correctas en tu proyecto:
import 'package:peoplesync/shared/themes/color_scheme.dart';
import 'package:peoplesync/shared/themes/text_theme.dart';

class AppTheme {
  static const double _borderRadius = 16.0;

  // 1. Definimos el estilo de la Card por separado para que sea más legible
  static CardThemeData _getCardTheme(ColorScheme colorScheme) {
    return CardThemeData(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip
          .antiAlias, // Para que el contenido no se salga de los bordes redondeados
    );
  }

  // 2. Definimos el estilo de la AppBar
  static AppBarTheme _getAppBarTheme(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return AppBarTheme(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: colorScheme.onSurface,
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurface),
    );
  }

  // 3. TEMA LIGHT
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: AppColorScheme.light,
    textTheme: AppTextTheme.light,
    scaffoldBackgroundColor: AppColorScheme.light.surface,

    // Asignamos los sub-temas
    appBarTheme: _getAppBarTheme(AppColorScheme.light, AppTextTheme.light),
    cardTheme: _getCardTheme(AppColorScheme.light),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColorScheme.light.primary,
      foregroundColor: AppColorScheme.light.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
    ),
  );

  // 4. TEMA DARK
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: AppColorScheme.dark,
    textTheme: AppTextTheme.dark,
    scaffoldBackgroundColor: AppColorScheme.dark.surface,

    // Asignamos los sub-temas
    appBarTheme: _getAppBarTheme(AppColorScheme.dark, AppTextTheme.dark),
    cardTheme: _getCardTheme(AppColorScheme.dark),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColorScheme.dark.primary,
      foregroundColor: AppColorScheme.dark.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
    ),
  );
}
