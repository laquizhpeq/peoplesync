import 'package:get_it/get_it.dart';
import 'package:peoplesync/features/auth/auth_service.dart';
import 'package:peoplesync/features/profile/profile_service.dart';
import 'package:peoplesync/features/navigation/navigation_service.dart';
import 'package:peoplesync/features/auth/auth_viewmodel.dart';
import 'package:peoplesync/features/profile/profile_viewmodel.dart';
import 'package:peoplesync/features/navigation/navigation_provider.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Services
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<ProfileService>(() => ProfileService());
  getIt.registerLazySingleton<NavigationService>(() => NavigationService());

  // ViewModels / Providers
  getIt.registerLazySingleton<NavigationProvider>(
    () => NavigationProvider(navigationService: getIt<NavigationService>()),
  );

  getIt.registerFactory<AuthViewModel>(
    () => AuthViewModel(
      authService: getIt<AuthService>(),
      navigationProvider: getIt<NavigationProvider>(),
    ),
  );
  getIt.registerFactory<ProfileViewModel>(
    () => ProfileViewModel(profileService: getIt<ProfileService>()),
  );
}
