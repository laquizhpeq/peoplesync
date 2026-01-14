import 'package:flutter/material.dart';

import 'core/constants/routes.dart';
import 'features/auth/auth_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PeopleSync',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: Routes.login,
      routes: {
        Routes.login: (context) => const AuthPage(),
        Routes.home: (context) => const AuthPage(),
      },
    );
  }
}
