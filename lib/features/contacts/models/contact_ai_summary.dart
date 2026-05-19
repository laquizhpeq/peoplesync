class ContactAiSummary {
  final String whoIs;
  final String whatConnectsYou;
  final String whatToRemember;
  final String nextStep;

  const ContactAiSummary({
    required this.whoIs,
    required this.whatConnectsYou,
    required this.whatToRemember,
    required this.nextStep,
  });

  factory ContactAiSummary.fromMap(Map<String, dynamic> map) {
    return ContactAiSummary(
      whoIs: (map['who_is'] as String? ?? '').trim(),
      whatConnectsYou: (map['what_connects_you'] as String? ?? '').trim(),
      whatToRemember: (map['what_to_remember'] as String? ?? '').trim(),
      nextStep: (map['next_step'] as String? ?? '').trim(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'who_is': whoIs,
      'what_connects_you': whatConnectsYou,
      'what_to_remember': whatToRemember,
      'next_step': nextStep,
    };
  }

  bool get hasContent =>
      whoIs.isNotEmpty ||
      whatConnectsYou.isNotEmpty ||
      whatToRemember.isNotEmpty ||
      nextStep.isNotEmpty;
}
