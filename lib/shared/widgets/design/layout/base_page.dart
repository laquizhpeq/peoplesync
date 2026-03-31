import 'package:flutter/material.dart';

class BasePage extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? footer;
  final bool centerBody;

  const BasePage({
    super.key,
    required this.title,
    required this.body,
    this.footer,
    this.centerBody = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: centerBody ? Center(child: body) : body,
      ),
      bottomNavigationBar: footer,
    );
  }
}
