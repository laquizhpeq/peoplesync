class SpotifyTrack {
  final String id;
  final String name;
  final String artist;
  final String? albumImageUrl;
  final String externalUrl;

  const SpotifyTrack({
    required this.id,
    required this.name,
    required this.artist,
    required this.externalUrl,
    this.albumImageUrl,
  });

  factory SpotifyTrack.fromMap(Map<String, dynamic> map) {
    final artists = (map['artists'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((artist) => artist['name'] as String? ?? '')
        .where((name) => name.trim().isNotEmpty)
        .toList();

    final album = map['album'] as Map<String, dynamic>? ?? const {};
    final images = (album['images'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .toList();
    final imageUrl = images.isNotEmpty
        ? images.first['url'] as String?
        : null;

    final externalUrls =
        map['external_urls'] as Map<String, dynamic>? ?? const {};

    return SpotifyTrack(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      artist: artists.isEmpty ? 'Artista desconocido' : artists.join(', '),
      albumImageUrl: imageUrl,
      externalUrl: externalUrls['spotify'] as String? ?? '',
    );
  }
}
