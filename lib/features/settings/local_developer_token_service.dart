import 'dart:math';

import 'package:peoplesync/features/auth/auth_service.dart';
import 'package:peoplesync/features/settings/models/developer_token_info.dart';
import 'package:peoplesync/features/settings/models/generated_developer_token.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalDeveloperTokenService {
  final AuthService authService;

  LocalDeveloperTokenService({required this.authService});

  Future<DeveloperTokenInfo> fetchTokenInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = _currentUid;
    final token = prefs.getString(_tokenKey(uid));
    final revokedAt = prefs.getString(_revokedAtKey(uid));

    return DeveloperTokenInfo(
      hasToken: token != null && token.isNotEmpty && revokedAt == null,
      tokenPrefix: token == null || token.isEmpty
          ? null
          : token.substring(0, min(12, token.length)),
      createdAt: _parseDateTime(prefs.getString(_createdAtKey(uid))),
      lastUsedAt: _parseDateTime(prefs.getString(_lastUsedAtKey(uid))),
      revokedAt: _parseDateTime(revokedAt),
    );
  }

  Future<GeneratedDeveloperToken> generateToken() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = _currentUid;
    final token = _generateToken();
    final createdAt = DateTime.now().toIso8601String();

    await prefs.setString(_tokenKey(uid), token);
    await prefs.setString(_createdAtKey(uid), createdAt);
    await prefs.remove(_revokedAtKey(uid));
    await prefs.remove(_lastUsedAtKey(uid));

    return GeneratedDeveloperToken(
      token: token,
      tokenPrefix: token.substring(0, min(12, token.length)),
      createdAt: DateTime.tryParse(createdAt),
      message: 'Este token es local y solo sirve dentro de tu app.',
    );
  }

  Future<void> revokeToken() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = _currentUid;

    await prefs.remove(_tokenKey(uid));
    await prefs.setString(
      _revokedAtKey(uid),
      DateTime.now().toIso8601String(),
    );
  }

  Future<String?> getActiveToken() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = _currentUid;
    final revokedAt = prefs.getString(_revokedAtKey(uid));
    if (revokedAt != null) return null;

    final token = prefs.getString(_tokenKey(uid));
    if (token == null || token.isEmpty) return null;
    return token;
  }

  Future<void> touchLastUsed() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = _currentUid;
    await prefs.setString(
      _lastUsedAtKey(uid),
      DateTime.now().toIso8601String(),
    );
  }

  String get _currentUid {
    final uid = authService.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw Exception('No hay un usuario autenticado.');
    }
    return uid;
  }

  String _generateToken() {
    final random = Random.secure();
    const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final buffer = StringBuffer('psk_local_');
    for (var index = 0; index < 40; index++) {
      buffer.write(alphabet[random.nextInt(alphabet.length)]);
    }
    return buffer.toString();
  }

  DateTime? _parseDateTime(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return DateTime.tryParse(value);
  }

  String _tokenKey(String uid) => 'developer_token_value_$uid';
  String _createdAtKey(String uid) => 'developer_token_created_at_$uid';
  String _lastUsedAtKey(String uid) => 'developer_token_last_used_at_$uid';
  String _revokedAtKey(String uid) => 'developer_token_revoked_at_$uid';
}
