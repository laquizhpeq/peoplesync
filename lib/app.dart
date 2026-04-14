import 'package:flutter/material.dart';
import 'package:peoplesync/shared/themes/app_theme.dart';

import 'package:provider/provider.dart';
import 'package:peoplesync/core/di/service_locator.dart';
import 'package:peoplesync/features/navigation/navigation_provider.dart';
import 'package:peoplesync/features/settings/theme_provider.dart';

import 'routes/app_routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NavigationProvider>.value(
          value: getIt<NavigationProvider>(),
        ),
        ChangeNotifierProvider<ThemeProvider>.value(
          value: getIt<ThemeProvider>(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: 'PeopleSync',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: AppRoutes.router,
          );
        },
      ),
    );
  }
}
