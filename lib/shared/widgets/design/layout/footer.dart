import 'package:flutter/material.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: const Center(
        child: Text('© 2026 PeopleSync', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
