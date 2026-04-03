import 'package:flutter/material.dart';
import 'package:peoplesync/core/di/service_locator.dart';
import 'package:peoplesync/features/auth/auth_service.dart';
import 'package:peoplesync/core/utils/route_utils.dart';
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
    final currentRoute = normalizeAppRoute(GoRouterState.of(context).uri.path);

    String pageTitle = 'PeopleSync';
    for (var m in navProvider.menus) {
      if (isSameAppRoute(m.route, currentRoute)) {
        pageTitle = m.title;
        break;
      }
    }

    if (currentRoute == '/contacts/new') {
      pageTitle = 'Nuevo contacto';
    }
    if (currentRoute == '/connections') {
      pageTitle = 'Conexiones';
    }
    if (currentRoute == '/profile/edit') {
      pageTitle = 'Editar perfil';
    }

    // Fallback if loading
    if (navProvider.isLoading) {
      pageTitle = 'Cargando...';
    }

    return Scaffold(
      extendBody: true,
      appBar: TopNavBar(title: pageTitle),
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
        child: SafeArea(top: false, child: widget.child),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
