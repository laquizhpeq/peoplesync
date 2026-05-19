import 'package:flutter/material.dart';
import 'package:peoplesync/shared/themes/app_theme.dart';

import 'package:provider/provider.dart';
import 'package:peoplesync/core/di/service_locator.dart';
import 'package:peoplesync/core/services/app_error_mapper.dart';
import 'package:peoplesync/core/services/app_feedback_service.dart';
import 'package:peoplesync/core/services/app_logger.dart';
import 'package:peoplesync/features/auth/auth_service.dart';
import 'package:peoplesync/features/contacts/connections_viewmodel.dart';
import 'package:peoplesync/features/navigation/navigation_provider.dart';
import 'package:peoplesync/features/profile/profile_service.dart';
import 'package:peoplesync/features/settings/local_api_server_service.dart';
import 'package:peoplesync/features/settings/theme_provider.dart';
import 'package:peoplesync/shared/widgets/common/app_runtime_error_view.dart';

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
    final localApiServerService = getIt<LocalApiServerService>();
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      AppLogger.info('Sesion vacia; limpiando estado global', scope: 'session');
      _bootstrappedUid = null;
      connectionsViewModel.clear();
      profileService.clearCache();
      navigationProvider.clearMenus();
      await localApiServerService.stop();
      return;
    }

    if (_bootstrappedUid != currentUser.uid) {
      AppLogger.debug(
        'Cambio de usuario detectado; invalidando cache de perfil',
        scope: 'session',
      );
      profileService.clearCache();
      _bootstrappedUid = currentUser.uid;
    }

    try {
      await profileService.ensureCurrentUserProfile();
      AppLogger.debug('Perfil del usuario asegurado', scope: 'session');
      final profile = profileService.cachedProfile;
      if (profile != null && !profile.isActive) {
        AppLogger.warning(
          'Se detecto una cuenta desactivada con sesion activa',
          scope: 'session',
        );
        await authService.signOut();
        connectionsViewModel.clear();
        navigationProvider.clearMenus();
        AppFeedbackService.showError(
          'Tu cuenta esta desactivada. Contacta con un administrador.',
        );
        return;
      }
      await connectionsViewModel.initialize();
      await localApiServerService.syncWithPreference();
      if (!navigationProvider.hasLoaded && !navigationProvider.isLoading) {
        await navigationProvider.loadMenus(currentUser.uid);
      }
    } catch (error, stackTrace) {
      AppLogger.error(
        'Fallo durante el bootstrap de sesion',
        scope: 'session',
        error: error,
        stackTrace: stackTrace,
      );
      AppFeedbackService.showError(
        'No se pudo preparar tu sesion. Reintenta o reinicia la app.',
      );
      return;
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
              scaffoldMessengerKey: AppFeedbackService.scaffoldMessengerKey,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.themeMode,
              routerConfig: AppRoutes.router,
              builder: (context, child) {
                ErrorWidget.builder = (details) {
                  AppLogger.error(
                    'Error al construir un widget',
                    scope: 'ui',
                    error: details.exception,
                    stackTrace: details.stack,
                  );
                  return AppRuntimeErrorView(
                    title: 'Esta parte de la app no se pudo mostrar',
                    description:
                        '${AppErrorMapper.toShortReason(details.exception)} Prueba a volver atras o recargar la pantalla.',
                  );
                };
                return child ?? const SizedBox.shrink();
              },
            );
          },
        );
      },
    );
  }
}
