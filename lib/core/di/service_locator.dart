import 'package:get_it/get_it.dart';
import 'package:peoplesync/features/admin/admin_service.dart';
import 'package:peoplesync/features/admin/admin_users_viewmodel.dart';
import 'package:peoplesync/features/assistant/assistant_chat_viewmodel.dart';
import 'package:peoplesync/features/assistant/assistant_service.dart';
import 'package:peoplesync/features/ai/ai_service.dart';
import 'package:peoplesync/features/ai/contact_ai_viewmodel.dart';
import 'package:peoplesync/features/contacts/contact_service.dart';
import 'package:peoplesync/features/contacts/contact_form_viewmodel.dart';
import 'package:peoplesync/features/contacts/connections_viewmodel.dart';
import 'package:peoplesync/features/contacts/models/contact_record.dart';
import 'package:peoplesync/features/auth/auth_service.dart';
import 'package:peoplesync/features/profile/profile_service.dart';
import 'package:peoplesync/features/profile/profile_editor_viewmodel.dart';
import 'package:peoplesync/features/profile/spotify_service.dart';
import 'package:peoplesync/features/navigation/navigation_service.dart';
import 'package:peoplesync/features/auth/auth_viewmodel.dart';
import 'package:peoplesync/features/profile/profile_viewmodel.dart';
import 'package:peoplesync/features/navigation/navigation_provider.dart';
import 'package:peoplesync/features/qr_code/qr_service.dart';
import 'package:peoplesync/features/contacts/contact_import_service.dart';
import 'package:peoplesync/features/contacts/local_contacts_cache_service.dart';
import 'package:peoplesync/features/contacts/contact_sync_viewmodel.dart';
import 'package:peoplesync/features/settings/local_api_server_service.dart';
import 'package:peoplesync/features/settings/local_developer_token_service.dart';
import 'package:peoplesync/features/settings/theme_provider.dart';
import 'package:peoplesync/features/settings/developer_token_service.dart';
import 'package:peoplesync/features/settings/developer_token_viewmodel.dart';
import 'package:peoplesync/pages/scanner/scanner_viewmodel.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Services
  getIt.registerLazySingleton<ContactService>(() => ContactService());
  getIt.registerLazySingleton<AdminService>(() => AdminService());
  getIt.registerLazySingleton<AssistantService>(() => AssistantService());
  getIt.registerLazySingleton<AiService>(() => AiService());
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<ProfileService>(() => ProfileService());
  getIt.registerLazySingleton<SpotifyService>(() => SpotifyService());
  getIt.registerLazySingleton<NavigationService>(() => NavigationService());
  getIt.registerLazySingleton<QrService>(() => QrService());
  getIt.registerLazySingleton<LocalContactsCacheService>(
    () => LocalContactsCacheService(),
  );
  getIt.registerLazySingleton<LocalDeveloperTokenService>(
    () => LocalDeveloperTokenService(authService: getIt<AuthService>()),
  );
  getIt.registerLazySingleton<LocalApiServerService>(
    () => LocalApiServerService(
      authService: getIt<AuthService>(),
      localDeveloperTokenService: getIt<LocalDeveloperTokenService>(),
      localContactsCacheService: getIt<LocalContactsCacheService>(),
    ),
  );
  getIt.registerLazySingleton<DeveloperTokenService>(
    () => DeveloperTokenService(
      localDeveloperTokenService: getIt<LocalDeveloperTokenService>(),
    ),
  );
  getIt.registerLazySingleton<ContactImportService>(
    () => ContactImportService(),
  );
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
      spotifyService: getIt<SpotifyService>(),
      markOnboardingCompleteOnSave: markOnboardingCompleteOnSave,
    ),
  );
  getIt.registerFactoryParam<ContactFormViewModel, ContactRecord?, void>(
    (initialContact, _) => ContactFormViewModel(
      contactService: getIt<ContactService>(),
      initialContact: initialContact,
    ),
  );
  getIt.registerLazySingleton<ConnectionsViewModel>(
    () => ConnectionsViewModel(
      contactService: getIt<ContactService>(),
      authService: getIt<AuthService>(),
      localContactsCacheService: getIt<LocalContactsCacheService>(),
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
  getIt.registerFactory<ContactSyncViewModel>(
    () => ContactSyncViewModel(
      importService: getIt<ContactImportService>(),
      contactService: getIt<ContactService>(),
      authService: getIt<AuthService>(),
    ),
  );
  getIt.registerFactory<AdminUsersViewModel>(
    () => AdminUsersViewModel(adminService: getIt<AdminService>()),
  );
  getIt.registerFactory<ContactAiViewModel>(
    () => ContactAiViewModel(aiService: getIt<AiService>()),
  );
  getIt.registerFactory<AssistantChatViewModel>(
    () => AssistantChatViewModel(
      assistantService: getIt<AssistantService>(),
      contactService: getIt<ContactService>(),
    ),
  );
  getIt.registerFactory<DeveloperTokenViewModel>(
    () => DeveloperTokenViewModel(
      developerTokenService: getIt<DeveloperTokenService>(),
      localApiServerService: getIt<LocalApiServerService>(),
      contactService: getIt<ContactService>(),
    ),
  );
}
