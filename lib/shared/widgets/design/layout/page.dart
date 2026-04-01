import 'package:flutter/material.dart';
import 'package:peoplesync/shared/widgets/design/layout/bottom_nav_bar.dart';
import 'package:peoplesync/shared/widgets/design/layout/app_bar.dart';

class Page extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget?
  bottomNavigationBar; // Cambiamos 'footer' por este nombre si prefieres
  final bool centerBody;

  const Page({
    super.key,
    required this.title,
    required this.body,
    this.bottomNavigationBar, // Lo añadimos aquí
    this.centerBody = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNavBar(title: title),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: centerBody ? Center(child: body) : body,
      ),
      // Usamos el parámetro que pasamos al constructor
      // Si es nulo, podemos poner uno por defecto o dejarlo nulo
      bottomNavigationBar: bottomNavigationBar ?? const BottomNavBar(),
    );
  }
}
