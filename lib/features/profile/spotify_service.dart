import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:peoplesync/core/config/env_config.dart';
import 'package:peoplesync/features/profile/models/spotify_track.dart';

class SpotifyServiceException implements Exception {
  final String message;

  const SpotifyServiceException(this.message);

  @override
  String toString() => message;
}

class SpotifyService {
  static final Uri _tokenUri = Uri.parse(
    'https://accounts.spotify.com/api/token',
  );
  static final Uri _searchUri = Uri.parse('https://api.spotify.com/v1/search');

  String? _cachedToken;
  DateTime? _tokenExpiryUtc;

  Future<List<SpotifyTrack>> searchTracks(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    final token = await _resolveToken();
    final uri = _searchUri.replace(
      queryParameters: {
        'q': trimmed,
        'type': 'track',
        'limit': '8',
      },
    );

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SpotifyServiceException(
        'Spotify no devolvio resultados (${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final tracks = decoded['tracks'] as Map<String, dynamic>? ?? const {};
    final items = (tracks['items'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => SpotifyTrack.fromMap(Map<String, dynamic>.from(item)))
        .where((track) => track.id.isNotEmpty && track.name.trim().isNotEmpty)
        .toList();
    return items;
  }

  Future<String> _resolveToken() async {
    final now = DateTime.now().toUtc();
    if (_cachedToken != null &&
        _tokenExpiryUtc != null &&
        now.isBefore(_tokenExpiryUtc!)) {
      return _cachedToken!;
    }

    final clientId = EnvConfig.spotifyClientId;
    final clientSecret = EnvConfig.spotifyClientSecret;
    if (clientId.isEmpty || clientSecret.isEmpty) {
      throw const SpotifyServiceException(
        'Falta SPOTIFY_CLIENT_ID o SPOTIFY_CLIENT_SECRET en .env.',
      );
    }

    final basic = base64Encode(utf8.encode('$clientId:$clientSecret'));
    final response = await http.post(
      _tokenUri,
      headers: {
        'Authorization': 'Basic $basic',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'grant_type=client_credentials',
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SpotifyServiceException(
        'No se pudo autenticar con Spotify (${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final accessToken = decoded['access_token'] as String? ?? '';
    final expiresIn = (decoded['expires_in'] as num?)?.toInt() ?? 3600;
    if (accessToken.trim().isEmpty) {
      throw const SpotifyServiceException(
        'Spotify no devolvio access token valido.',
      );
    }

    _cachedToken = accessToken;
    _tokenExpiryUtc = now.add(Duration(seconds: expiresIn - 30));
    return accessToken;
  }
}
