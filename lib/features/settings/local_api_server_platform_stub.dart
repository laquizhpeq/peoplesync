import 'package:peoplesync/features/auth/auth_service.dart';
import 'package:peoplesync/features/contacts/local_contacts_cache_service.dart';
import 'package:peoplesync/features/settings/local_api_server_platform.dart';
import 'package:peoplesync/features/settings/local_developer_token_service.dart';

class StubLocalApiServerPlatform implements LocalApiServerPlatform {
  @override
  bool get isSupported => false;

  @override
  bool get isRunning => false;

  @override
  int? get port => null;

  @override
  List<String> get urls => const [];

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}
}

LocalApiServerPlatform createLocalApiServerPlatform({
  required AuthService authService,
  required LocalDeveloperTokenService localDeveloperTokenService,
  required LocalContactsCacheService localContactsCacheService,
}) {
  return StubLocalApiServerPlatform();
}
