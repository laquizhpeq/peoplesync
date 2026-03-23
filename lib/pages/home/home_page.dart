import 'package:flutter/material.dart';
import 'package:peoplesync/core/constants/app_strings.dart';
import 'package:peoplesync/shared/widgets/base/layout/base_page.dart';
import 'package:peoplesync/shared/widgets/design/bottom_nav/bottom_nav_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: AppStrings.home,
      body: const Center(child: Text('Página de inicio – contenido de prueba')),
      footer: const BottomNavBar(),
    );
  }
}
