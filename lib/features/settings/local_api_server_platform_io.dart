import 'dart:convert';
import 'dart:io';

import 'package:peoplesync/features/auth/auth_service.dart';
import 'package:peoplesync/features/contacts/local_contacts_cache_service.dart';
import 'package:peoplesync/features/settings/local_api_server_platform.dart';
import 'package:peoplesync/features/settings/local_developer_token_service.dart';

class IoLocalApiServerPlatform implements LocalApiServerPlatform {
  final AuthService authService;
  final LocalDeveloperTokenService localDeveloperTokenService;
  final LocalContactsCacheService localContactsCacheService;

  HttpServer? _server;
  List<String> _urls = const [];

  IoLocalApiServerPlatform({
    required this.authService,
    required this.localDeveloperTokenService,
    required this.localContactsCacheService,
  });

  @override
  bool get isSupported => true;

  @override
  bool get isRunning => _server != null;

  @override
  int? get port => _server?.port;

  @override
  List<String> get urls => _urls;

  @override
  Future<void> start() async {
    if (_server != null) return;

    final server = await HttpServer.bind(InternetAddress.anyIPv4, 8787);
    _server = server;
    _urls = await _resolveUrls(server.port);
    server.listen(_handleRequest);
  }

  @override
  Future<void> stop() async {
    final server = _server;
    _server = null;
    _urls = const [];
    await server?.close(force: true);
  }

  Future<void> _handleRequest(HttpRequest request) async {
    try {
      final path = request.uri.path;
      if (request.method == 'GET' && path == '/v1/health') {
        await _writeJson(request.response, HttpStatus.ok, {
          'data': {
            'ok': true,
            'service': 'peoplesync-local-api',
            'timestamp': DateTime.now().toUtc().toIso8601String(),
          },
        });
        return;
      }

      if (request.method == 'GET' && path == '/v1/contacts/export') {
        final authHeader = request.headers.value(
          HttpHeaders.authorizationHeader,
        );
        final token = await localDeveloperTokenService.getActiveToken();

        if (token == null || token.isEmpty) {
          await _writeJson(request.response, HttpStatus.unauthorized, {
            'error': {
              'code': 'missing_token',
              'message': 'No hay token local activo.',
            },
          });
          return;
        }

        if (authHeader == null || authHeader.trim() != 'Bearer $token') {
          await _writeJson(request.response, HttpStatus.unauthorized, {
            'error': {
              'code': 'invalid_token',
              'message': 'El token local no es valido.',
            },
          });
          return;
        }

        final uid = authService.currentUser?.uid;
        if (uid == null || uid.isEmpty) {
          await _writeJson(request.response, HttpStatus.unauthorized, {
            'error': {
              'code': 'missing_user',
              'message': 'No hay un usuario autenticado en la app.',
            },
          });
          return;
        }

        final contacts = await localContactsCacheService.readContacts(uid);
        await localDeveloperTokenService.touchLastUsed();

        await _writeJson(request.response, HttpStatus.ok, {
          'data': {
            'exported_at': DateTime.now().toUtc().toIso8601String(),
            'owner_uid': uid,
            'count': contacts.length,
            'contacts': contacts.map((contact) => contact.toJsonMap()).toList(),
          },
        });
        return;
      }

      await _writeJson(request.response, HttpStatus.notFound, {
        'error': {'code': 'not_found', 'message': 'Endpoint no encontrado.'},
      });
    } catch (error) {
      await _writeJson(request.response, HttpStatus.internalServerError, {
        'error': {
          'code': 'internal_error',
          'message': 'Fallo el servidor local.',
          'details': '$error',
        },
      });
    }
  }

  Future<void> _writeJson(
    HttpResponse response,
    int statusCode,
    Map<String, dynamic> payload,
  ) async {
    response.statusCode = statusCode;
    response.headers.contentType = ContentType.json;
    response.write(jsonEncode(payload));
    await response.close();
  }

  Future<List<String>> _resolveUrls(int port) async {
    final urls = <String>{'http://127.0.0.1:$port'};
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );

    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        urls.add('http://${address.address}:$port');
      }
    }

    return urls.toList()..sort();
  }
}

LocalApiServerPlatform createLocalApiServerPlatform({
  required AuthService authService,
  required LocalDeveloperTokenService localDeveloperTokenService,
  required LocalContactsCacheService localContactsCacheService,
}) {
  return IoLocalApiServerPlatform(
    authService: authService,
    localDeveloperTokenService: localDeveloperTokenService,
    localContactsCacheService: localContactsCacheService,
  );
}
