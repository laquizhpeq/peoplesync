import 'package:peoplesync/features/settings/local_developer_token_service.dart';
import 'package:peoplesync/features/settings/models/developer_token_info.dart';
import 'package:peoplesync/features/settings/models/generated_developer_token.dart';

class DeveloperTokenService {
  final LocalDeveloperTokenService localDeveloperTokenService;

  DeveloperTokenService({
    required this.localDeveloperTokenService,
  });

  Future<DeveloperTokenInfo> fetchTokenInfo() async {
    return localDeveloperTokenService.fetchTokenInfo();
  }

  Future<GeneratedDeveloperToken> generateToken() async {
    return localDeveloperTokenService.generateToken();
  }

  Future<void> revokeToken() async {
    await localDeveloperTokenService.revokeToken();
  }
}
