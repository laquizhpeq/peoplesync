import 'package:flutter/material.dart';
import 'package:peoplesync/core/di/service_locator.dart';
import 'package:peoplesync/features/auth/auth_service.dart';
import 'package:peoplesync/shared/widgets/design/layout/app_bar.dart';
import 'package:peoplesync/shared/widgets/design/layout/bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:peoplesync/features/navigation/navigation_provider.dart';
import 'package:go_router/go_router.dart';

class AppLayout extends StatefulWidget {
  final Widget child;

  const AppLayout({super.key, required this.child});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  @override
  void initState() {
    super.initState();
    _checkInitialLoad();
  }

  void _checkInitialLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navProvider = Provider.of<NavigationProvider>(
        context,
        listen: false,
      );
      final authService = getIt<AuthService>();
      final currentUser = authService.currentUser;

      if (currentUser != null &&
          !navProvider.hasLoaded &&
          !navProvider.isLoading) {
        // ignore: avoid_print
        print('AppLayout: Triggering initial menu load for ${currentUser.uid}');
        navProvider.loadMenus(currentUser.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final currentRoute = GoRouterState.of(context).uri.path;

    // Find if the current route matches any menu
    String pageTitle = 'PeopleSync';
    for (var m in navProvider.menus) {
      if (m.route == currentRoute) {
        pageTitle = m.title;
        break;
      }
    }

    // Fallback if loading
    if (navProvider.isLoading) {
      pageTitle = 'Cargando...';
    }

    return Scaffold(
      appBar: TopNavBar(title: pageTitle),
      body: widget.child,
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
