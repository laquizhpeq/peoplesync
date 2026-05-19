import 'package:peoplesync/features/auth/auth_service.dart';
import 'package:peoplesync/features/contacts/local_contacts_cache_service.dart';
import 'package:peoplesync/features/settings/local_api_server_platform.dart';
import 'package:peoplesync/features/settings/local_developer_token_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'local_api_server_platform_stub.dart'
    if (dart.library.io) 'local_api_server_platform_io.dart'
    as platform_impl;

class LocalApiServerService {
  final LocalApiServerPlatform _platform;

  LocalApiServerService({
    required AuthService authService,
    required LocalDeveloperTokenService localDeveloperTokenService,
    required LocalContactsCacheService localContactsCacheService,
  }) : _platform = platform_impl.createLocalApiServerPlatform(
         authService: authService,
         localDeveloperTokenService: localDeveloperTokenService,
         localContactsCacheService: localContactsCacheService,
       );

  bool get isSupported => _platform.isSupported;
  bool get isRunning => _platform.isRunning;
  int? get port => _platform.port;
  List<String> get urls => _platform.urls;

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_developerModeEnabledKey) ?? false;
  }

  Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_developerModeEnabledKey, value);
    if (value && isSupported) {
      await _platform.start();
      return;
    }
    await _platform.stop();
  }

  Future<void> syncWithPreference() async {
    final enabled = await isEnabled();
    if (enabled && isSupported) {
      await _platform.start();
      return;
    }
    await _platform.stop();
  }

  Future<void> stop() async {
    await _platform.stop();
  }

  static const String _developerModeEnabledKey =
      'developer_mode_enabled_local_api';
}
