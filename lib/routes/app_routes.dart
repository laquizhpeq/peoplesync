import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:peoplesync/core/constants/routes.dart';
import 'package:peoplesync/pages/home/home_page.dart';
import 'package:peoplesync/pages/auth/auth_page.dart';
import 'package:peoplesync/pages/auth/register_page.dart';
import 'package:peoplesync/pages/contacts/contact_form_page.dart';
import 'package:peoplesync/pages/contacts/connections_page.dart';
import 'package:peoplesync/pages/profile/profile_page.dart';
import 'package:peoplesync/pages/profile/profile_editor_page.dart';
import 'package:peoplesync/features/auth/auth_service.dart';
import 'package:peoplesync/features/auth/auth_viewmodel.dart';
import 'package:peoplesync/features/navigation/navigation_provider.dart';
import 'package:peoplesync/features/profile/profile_service.dart';
import 'package:peoplesync/core/di/service_locator.dart';
import 'package:peoplesync/core/utils/route_utils.dart';
import 'package:peoplesync/shared/widgets/design/layout/app_layout.dart';

class AppRoutes {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.login,
    redirect: (context, state) async {
      final authService = getIt<AuthService>();
      final profileService = getIt<ProfileService>();
      final isAuth = authService.currentUser != null;
      final path = normalizeAppRoute(state.uri.path);
      final isAuthRoute = path == Routes.login || path == Routes.register;
      final isOnboardingRoute = path == Routes.onboardingProfile;

      if (!isAuth && !isAuthRoute) {
        return Routes.login;
      }

      if (isAuth) {
        await profileService.ensureCurrentUserProfile();
        final needsOnboarding = await profileService.requiresOnboarding();

        if (needsOnboarding && !isOnboardingRoute) {
          return Routes.onboardingProfile;
        }

        if (!needsOnboarding && isOnboardingRoute) {
          return Routes.home;
        }

        if (isAuthRoute) {
          return needsOnboarding ? Routes.onboardingProfile : Routes.home;
        }
      }

      // Authorization check from the fetched db menus
      if (isAuth && !isOnboardingRoute) {
        final navProvider = getIt<NavigationProvider>();
        if (!navProvider.isLoading && !navProvider.isAuthorized(path)) {
          return Routes.home;
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: Routes.login,
        builder: (context, state) => ChangeNotifierProvider<AuthViewModel>(
          create: (_) => getIt<AuthViewModel>(),
          child: const AuthPage(),
        ),
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, state) => ChangeNotifierProvider<AuthViewModel>(
          create: (_) => getIt<AuthViewModel>(),
          child: const RegisterPage(),
        ),
      ),
      GoRoute(
        path: Routes.onboardingProfile,
        builder: (context, state) => const ProfileEditorPage(isOnboarding: true),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AppLayout(child: child);
        },
        routes: [
          GoRoute(
            path: Routes.homeAlias,
            redirect: (context, state) => Routes.home,
          ),
          GoRoute(
            path: Routes.home,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: Routes.connections,
            builder: (context, state) => const ConnectionsPage(),
          ),
          GoRoute(
            path: Routes.profile,
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: Routes.profileEdit,
            builder: (context, state) => const ProfileEditorPage(),
          ),
          GoRoute(
            path: Routes.contactNew,
            builder: (context, state) => const ContactFormPage(),
          ),
        ],
      ),
    ],
  );
}
