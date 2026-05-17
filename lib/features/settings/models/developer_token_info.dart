class DeveloperTokenInfo {
  final bool hasToken;
  final String? tokenPrefix;
  final DateTime? createdAt;
  final DateTime? lastUsedAt;
  final DateTime? revokedAt;

  const DeveloperTokenInfo({
    required this.hasToken,
    required this.tokenPrefix,
    required this.createdAt,
    required this.lastUsedAt,
    required this.revokedAt,
  });

  factory DeveloperTokenInfo.fromJson(Map<String, dynamic> json) {
    return DeveloperTokenInfo(
      hasToken: json['has_token'] == true,
      tokenPrefix: json['token_prefix'] as String?,
      createdAt: _parseDateTime(json['created_at']),
      lastUsedAt: _parseDateTime(json['last_used_at']),
      revokedAt: _parseDateTime(json['revoked_at']),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is! String || value.trim().isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
