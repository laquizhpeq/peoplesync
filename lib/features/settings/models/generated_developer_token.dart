class GeneratedDeveloperToken {
  final String token;
  final String tokenPrefix;
  final DateTime? createdAt;
  final String? message;

  const GeneratedDeveloperToken({
    required this.token,
    required this.tokenPrefix,
    required this.createdAt,
    required this.message,
  });

  factory GeneratedDeveloperToken.fromJson(Map<String, dynamic> json) {
    return GeneratedDeveloperToken(
      token: (json['token'] as String?)?.trim() ?? '',
      tokenPrefix: (json['token_prefix'] as String?)?.trim() ?? '',
      createdAt: _parseDateTime(json['created_at']),
      message: json['message'] as String?,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is! String || value.trim().isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
