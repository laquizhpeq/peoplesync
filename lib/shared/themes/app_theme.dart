import 'package:flutter/material.dart';
import 'package:peoplesync/shared/themes/text_theme.dart';

import 'color_scheme.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: AppColorScheme.light,
    textTheme: AppTextTheme.light,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: AppColorScheme.dark,
    textTheme: AppTextTheme.dark,
  );
}
