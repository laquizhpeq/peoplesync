import 'package:flutter/material.dart';

import 'app_bar.dart';
import 'footer.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget child;

  const AppScaffold({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: title),
      body: child,
      bottomNavigationBar: const FooterWidget(),
    );
  }
}
