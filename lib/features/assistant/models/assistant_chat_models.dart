import 'package:peoplesync/features/contacts/models/contact_record.dart';

enum AssistantChatRole { user, assistant, system }

enum AssistantConversationMode {
  normal,
  awaitingCreateConfirmation,
  collectingContactData,
  readyToCreate,
}

class AssistantChatMessage {
  final String id;
  final AssistantChatRole role;
  final String text;
  final DateTime createdAt;

  const AssistantChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
  });
}

class AssistantCreateContactDraft {
  final String displayName;
  final String? phone;
  final String? email;
  final String? city;
  final String? company;
  final String? jobTitle;
  final String? bio;
  final String? about;
  final String? relationshipType;
  final List<String> interests;
  final List<String> lookingFor;
  final List<String> personalityTags;
  final String? contextNote;
  final String? lastInteractionNote;

  const AssistantCreateContactDraft({
    required this.displayName,
    this.phone,
    this.email,
    this.city,
    this.company,
    this.jobTitle,
    this.bio,
    this.about,
    this.relationshipType,
    this.interests = const [],
    this.lookingFor = const [],
    this.personalityTags = const [],
    this.contextNote,
    this.lastInteractionNote,
  });

  ContactIdentity toIdentity() {
    return ContactIdentity(
      displayName: displayName,
      phone: phone,
      email: email,
      city: city,
      company: company,
      jobTitle: jobTitle,
      bio: bio,
      about: about,
    );
  }

  ContactRelationship toRelationship() {
    return ContactRelationship(
      relationshipType: relationshipType,
      interests: interests,
      lookingFor: lookingFor,
      personalityTags: personalityTags,
      contextNote: contextNote,
      lastInteractionNote: lastInteractionNote,
    );
  }
}

class AssistantToolCall {
  final String name;
  final Map<String, dynamic> arguments;

  const AssistantToolCall({required this.name, required this.arguments});
}

class AssistantTurnResult {
  final String reply;
  final AssistantToolCall? toolCall;
  final String model;
  final AssistantConversationMode conversationMode;

  const AssistantTurnResult({
    required this.reply,
    required this.model,
    required this.conversationMode,
    this.toolCall,
  });
}
