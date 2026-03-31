import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:peoplesync/pages/home/home_page.dart';
import 'package:peoplesync/pages/auth/auth_page.dart';
import 'package:peoplesync/pages/profile/profile_page.dart';
import 'package:peoplesync/features/auth/auth_service.dart';
import 'package:peoplesync/features/auth/auth_viewmodel.dart';
import 'package:peoplesync/features/navigation/navigation_provider.dart';
import 'package:peoplesync/core/di/service_locator.dart';
import 'package:peoplesync/shared/widgets/design/layout/app_layout.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String profile = '/profile';

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: login,
    redirect: (context, state) {
      final authService = getIt<AuthService>();
      final isAuth = authService.currentUser != null;

      if (!isAuth && state.uri.path != login) {
        return login;
      }

      if (isAuth && state.uri.path == login) {
        return home;
      }

      // Authorization check from the fetched db menus
      if (isAuth) {
        final navProvider = getIt<NavigationProvider>();
        if (!navProvider.isLoading &&
            !navProvider.isAuthorized(state.uri.path)) {
          return home;
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: login,
        builder: (context, state) => ChangeNotifierProvider<AuthViewModel>(
          create: (_) => getIt<AuthViewModel>(),
          child: const AuthPage(),
        ),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AppLayout(child: child);
        },
        routes: [
          GoRoute(path: home, builder: (context, state) => const HomePage()),
          GoRoute(
            path: profile,
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
    ],
  );
}
