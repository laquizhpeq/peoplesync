import 'package:flutter/material.dart';
import 'package:peoplesync/shared/themes/app_theme.dart';

import 'core/constants/routes.dart';
import 'features/auth/auth_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PeopleSync',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: Routes.login,
      routes: {
        Routes.login: (context) => const AuthPage(),
        Routes.home: (context) => const AuthPage(),
      },
    );
  }
}
