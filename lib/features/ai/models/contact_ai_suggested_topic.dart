class ContactAiSuggestedTopic {
  final String openingAngle;
  final String iceBreaker;
  final List<String> conversationTopics;

  const ContactAiSuggestedTopic({
    required this.openingAngle,
    required this.iceBreaker,
    required this.conversationTopics,
  });

  factory ContactAiSuggestedTopic.fromMap(Map<String, dynamic> map) {
    return ContactAiSuggestedTopic(
      openingAngle: (map['opening_angle'] as String? ?? '').trim(),
      iceBreaker: (map['ice_breaker'] as String? ?? '').trim(),
      conversationTopics: List<String>.from(
        (map['conversation_topics'] as List<dynamic>? ?? const [])
            .whereType<String>()
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty),
      ),
    );
  }

  bool get hasContent =>
      openingAngle.isNotEmpty ||
      iceBreaker.isNotEmpty ||
      conversationTopics.isNotEmpty;
}
