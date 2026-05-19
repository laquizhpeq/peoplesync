class ContactAiMessageSuggestion {
  final String message;
  final String? intent;

  const ContactAiMessageSuggestion({required this.message, this.intent});

  factory ContactAiMessageSuggestion.fromMap(Map<String, dynamic> map) {
    return ContactAiMessageSuggestion(
      message: (map['message'] as String? ?? '').trim(),
      intent: (map['intent'] as String?)?.trim(),
    );
  }

  bool get hasContent => message.isNotEmpty;
}
