import 'package:get_it/get_it.dart';
import 'package:peoplesync/features/contacts/contact_service.dart';
import 'package:peoplesync/features/contacts/contact_form_viewmodel.dart';
import 'package:peoplesync/features/contacts/connections_viewmodel.dart';
import 'package:peoplesync/features/contacts/models/contact_record.dart';
import 'package:peoplesync/features/auth/auth_service.dart';
import 'package:peoplesync/features/profile/profile_service.dart';
import 'package:peoplesync/features/profile/profile_editor_viewmodel.dart';
import 'package:peoplesync/features/navigation/navigation_service.dart';
import 'package:peoplesync/features/auth/auth_viewmodel.dart';
import 'package:peoplesync/features/profile/profile_viewmodel.dart';
import 'package:peoplesync/features/navigation/navigation_provider.dart';
import 'package:peoplesync/features/qr_code/qr_service.dart';
import 'package:peoplesync/features/settings/theme_provider.dart';
import 'package:peoplesync/pages/scanner/scanner_viewmodel.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Services
  getIt.registerLazySingleton<ContactService>(() => ContactService());
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<ProfileService>(() => ProfileService());
  getIt.registerLazySingleton<NavigationService>(() => NavigationService());
  getIt.registerLazySingleton<QrService>(() => QrService());
  getIt.registerLazySingleton<ThemeProvider>(() => ThemeProvider());

  // ViewModels / Providers
  getIt.registerLazySingleton<NavigationProvider>(
    () => NavigationProvider(navigationService: getIt<NavigationService>()),
  );

  getIt.registerFactory<AuthViewModel>(
    () => AuthViewModel(
      authService: getIt<AuthService>(),
      profileService: getIt<ProfileService>(),
      navigationProvider: getIt<NavigationProvider>(),
    ),
  );
  getIt.registerFactory<ProfileViewModel>(
    () => ProfileViewModel(profileService: getIt<ProfileService>()),
  );
  getIt.registerFactoryParam<ProfileEditorViewModel, bool, void>(
    (markOnboardingCompleteOnSave, _) => ProfileEditorViewModel(
      profileService: getIt<ProfileService>(),
      markOnboardingCompleteOnSave: markOnboardingCompleteOnSave,
    ),
  );
  getIt.registerFactoryParam<ContactFormViewModel, ContactRecord?, void>(
    (initialContact, _) => ContactFormViewModel(
      contactService: getIt<ContactService>(),
      initialContact: initialContact,
    ),
  );
  getIt.registerFactory<ConnectionsViewModel>(
    () => ConnectionsViewModel(
      contactService: getIt<ContactService>(),
      authService: getIt<AuthService>(),
    ),
  );
  getIt.registerFactory<ScannerViewModel>(
    () => ScannerViewModel(
      contactService: getIt<ContactService>(),
      profileService: getIt<ProfileService>(),
      authService: getIt<AuthService>(),
      qrService: getIt<QrService>(),
    ),
  );
}
