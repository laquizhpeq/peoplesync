import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AppBarWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// 2. Crea la previsualización aquí abajo
@Preview(name: 'App Bar Standard')
Widget previewAppBar() {
  return const MaterialApp(
    home: Scaffold(appBar: AppBarWidget(title: 'Mi Título de Prueba')),
  );
}
