import 'package:flutter/material.dart';
import 'package:peoplesync/shared/widgets/design/layout/bottom_nav_bar.dart';

class AppLayout extends StatelessWidget {
  final Widget child;

  const AppLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.32),
              Theme.of(context).colorScheme.surface,
              Theme.of(
                context,
              ).colorScheme.secondaryContainer.withValues(alpha: 0.18),
            ],
          ),
        ),
        child: SafeArea(minimum: const EdgeInsets.only(top: 8), child: child),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
