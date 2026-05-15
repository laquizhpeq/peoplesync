import 'package:flutter/material.dart';
import 'package:peoplesync/shared/themes/app_theme.dart';

import 'package:provider/provider.dart';
import 'package:peoplesync/core/di/service_locator.dart';
import 'package:peoplesync/features/auth/auth_service.dart';
import 'package:peoplesync/features/contacts/connections_viewmodel.dart';
import 'package:peoplesync/features/navigation/navigation_provider.dart';
import 'package:peoplesync/features/profile/profile_service.dart';
import 'package:peoplesync/features/settings/theme_provider.dart';

import 'core/constants/routes.dart';
import 'core/utils/route_utils.dart';
import 'routes/app_routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NavigationProvider>.value(
          value: getIt<NavigationProvider>(),
        ),
        ChangeNotifierProvider<ThemeProvider>.value(
          value: getIt<ThemeProvider>(),
        ),
        ChangeNotifierProvider<ConnectionsViewModel>.value(
          value: getIt<ConnectionsViewModel>(),
        ),
      ],
      child: const _SessionBootstrap(),
    );
  }
}

class _SessionBootstrap extends StatefulWidget {
  const _SessionBootstrap();

  @override
  State<_SessionBootstrap> createState() => _SessionBootstrapState();
}

class _SessionBootstrapState extends State<_SessionBootstrap> {
  String? _bootstrappedUid;
  Future<void>? _bootstrapTask;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncSessionState();
    });
  }

  void _syncSessionState() {
    _bootstrapTask ??= _bootstrapSession();
    _bootstrapTask!.whenComplete(() {
      _bootstrapTask = null;
    });
  }

  Future<void> _bootstrapSession() async {
    final authService = getIt<AuthService>();
    final connectionsViewModel = getIt<ConnectionsViewModel>();
    final navigationProvider = getIt<NavigationProvider>();
    final profileService = getIt<ProfileService>();
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      _bootstrappedUid = null;
      connectionsViewModel.clear();
      profileService.clearCache();
      navigationProvider.clearMenus();
      return;
    }

    if (_bootstrappedUid != currentUser.uid) {
      profileService.clearCache();
      _bootstrappedUid = currentUser.uid;
    }

    await profileService.ensureCurrentUserProfile();
    connectionsViewModel.initialize();
    if (!navigationProvider.hasLoaded && !navigationProvider.isLoading) {
      await navigationProvider.loadMenus(currentUser.uid);
    }

    final needsOnboarding = profileService.requiresOnboardingFromCache();
    if (needsOnboarding == null) return;

    final currentPath = normalizeAppRoute(
      AppRoutes.router.routeInformationProvider.value.uri.path,
    );

    if (needsOnboarding && currentPath != Routes.onboardingProfile) {
      AppRoutes.router.go(Routes.onboardingProfile);
      return;
    }

    if (!needsOnboarding &&
        (currentPath == Routes.login ||
            currentPath == Routes.register ||
            currentPath == Routes.onboardingProfile)) {
      AppRoutes.router.go(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: getIt<AuthService>().authStateChanges,
      builder: (context, snapshot) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _syncSessionState();
        });

        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return MaterialApp.router(
              title: 'PeopleSync',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.themeMode,
              routerConfig: AppRoutes.router,
            );
          },
        );
      },
    );
  }
}
