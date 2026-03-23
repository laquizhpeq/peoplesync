import 'package:get_it/get_it.dart';
import 'package:peoplesync/features/auth/auth_service.dart';
import 'package:peoplesync/features/profile/profile_service.dart';
import 'package:peoplesync/features/auth/auth_viewmodel.dart';
import 'package:peoplesync/features/profile/profile_viewmodel.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Services
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<ProfileService>(() => ProfileService());

  // ViewModels (Factory allows creating a new instance when requested to avoid lingering state, 
  // or they can be Singletons if global state is required. For now, Factory is safe for pages,
  // but if we need global state later, we can change it to registerLazySingleton).
  getIt.registerFactory<AuthViewModel>(
    () => AuthViewModel(authService: getIt<AuthService>()),
  );
  getIt.registerFactory<ProfileViewModel>(
    () => ProfileViewModel(profileService: getIt<ProfileService>()),
  );
}
