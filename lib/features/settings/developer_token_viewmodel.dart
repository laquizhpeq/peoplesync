import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:peoplesync/core/services/app_logger.dart';
import 'package:peoplesync/features/contacts/contact_service.dart';
import 'package:peoplesync/features/settings/developer_token_service.dart';
import 'package:peoplesync/features/settings/local_api_server_service.dart';
import 'package:peoplesync/features/settings/models/developer_token_info.dart';
import 'package:peoplesync/features/settings/models/generated_developer_token.dart';

class DeveloperTokenViewModel extends ChangeNotifier {
  final DeveloperTokenService developerTokenService;
  final LocalApiServerService localApiServerService;
  final ContactService contactService;

  DeveloperTokenInfo? _tokenInfo;
  bool _isLoading = true;
  bool _isGenerating = false;
  bool _isRevoking = false;
  bool _isUpdatingDeveloperMode = false;
  bool _isExporting = false;
  bool _developerModeEnabled = false;
  String? _errorMessage;

  DeveloperTokenInfo? get tokenInfo => _tokenInfo;
  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;
  bool get isRevoking => _isRevoking;
  bool get isUpdatingDeveloperMode => _isUpdatingDeveloperMode;
  bool get isExporting => _isExporting;
  bool get developerModeEnabled => _developerModeEnabled;
  bool get isServerSupported => localApiServerService.isSupported;
  bool get isServerRunning => localApiServerService.isRunning;
  int? get serverPort => localApiServerService.port;
  List<String> get serverUrls => localApiServerService.urls;
  String? get errorMessage => _errorMessage;
  bool get hasToken => _tokenInfo?.hasToken == true;

  DeveloperTokenViewModel({
    required this.developerTokenService,
    required this.localApiServerService,
    required this.contactService,
  }) {
    initialize();
  }

  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _developerModeEnabled = await localApiServerService.isEnabled();
      _tokenInfo = await developerTokenService.fetchTokenInfo();
      AppLogger.debug(
        'Estado del token de desarrollador cargado',
        scope: 'developer-token',
      );
    } catch (error, stackTrace) {
      _errorMessage = 'No se pudo cargar el estado del token.';
      AppLogger.error(
        'Fallo al cargar el token de desarrollador',
        scope: 'developer-token',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<GeneratedDeveloperToken> generateToken() async {
    _isGenerating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final generatedToken = await developerTokenService.generateToken();
      _tokenInfo = await developerTokenService.fetchTokenInfo();
      AppLogger.info(
        'Token de desarrollador regenerado',
        scope: 'developer-token',
      );
      return generatedToken;
    } catch (error, stackTrace) {
      _errorMessage = 'No se pudo generar el token.';
      AppLogger.error(
        'Fallo al generar el token de desarrollador',
        scope: 'developer-token',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  Future<void> revokeToken() async {
    _isRevoking = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await developerTokenService.revokeToken();
      _tokenInfo = await developerTokenService.fetchTokenInfo();
      AppLogger.info(
        'Token de desarrollador revocado',
        scope: 'developer-token',
      );
    } catch (error, stackTrace) {
      _errorMessage = 'No se pudo revocar el token.';
      AppLogger.error(
        'Fallo al revocar el token de desarrollador',
        scope: 'developer-token',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    } finally {
      _isRevoking = false;
      notifyListeners();
    }
  }

  Future<void> setDeveloperModeEnabled(bool value) async {
    _isUpdatingDeveloperMode = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await localApiServerService.setEnabled(value);
      _developerModeEnabled = value;
      AppLogger.info(
        value
            ? 'Modo desarrollador activado'
            : 'Modo desarrollador desactivado',
        scope: 'developer-token',
      );
    } catch (error, stackTrace) {
      _errorMessage = 'No se pudo cambiar el modo desarrollador.';
      AppLogger.error(
        'Fallo al cambiar el modo desarrollador',
        scope: 'developer-token',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    } finally {
      _isUpdatingDeveloperMode = false;
      notifyListeners();
    }
  }

  Future<String> exportContactsJson() async {
    _isExporting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final contacts = await contactService.fetchContacts();
      final payload = {
        'data': {
          'exported_at': DateTime.now().toUtc().toIso8601String(),
          'count': contacts.length,
          'contacts': contacts.map((contact) => contact.toJsonMap()).toList(),
        },
      };
      return const JsonEncoder.withIndent('  ').convert(payload);
    } catch (error, stackTrace) {
      _errorMessage = 'No se pudo exportar el JSON de contactos.';
      AppLogger.error(
        'Fallo al exportar contactos a JSON',
        scope: 'developer-token',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }
}
