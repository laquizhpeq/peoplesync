import 'package:cloud_firestore/cloud_firestore.dart';

enum ContactSource { manual, deviceImport, linkedUser, qrImport }

enum SocialPlatform {
  instagram,
  x,
  tiktok,
  linkedin,
  facebook,
  telegram,
  whatsapp,
  youtube,
  twitch,
  snapchat,
  website,
  other,
}

SocialPlatform socialPlatformFromValue(String? value) {
  switch (value) {
    case 'instagram':
      return SocialPlatform.instagram;
    case 'x':
      return SocialPlatform.x;
    case 'tiktok':
      return SocialPlatform.tiktok;
    case 'linkedin':
      return SocialPlatform.linkedin;
    case 'facebook':
      return SocialPlatform.facebook;
    case 'telegram':
      return SocialPlatform.telegram;
    case 'whatsapp':
      return SocialPlatform.whatsapp;
    case 'youtube':
      return SocialPlatform.youtube;
    case 'twitch':
      return SocialPlatform.twitch;
    case 'snapchat':
      return SocialPlatform.snapchat;
    case 'website':
      return SocialPlatform.website;
    default:
      return SocialPlatform.other;
  }
}

String socialPlatformValue(SocialPlatform platform) {
  return switch (platform) {
    SocialPlatform.instagram => 'instagram',
    SocialPlatform.x => 'x',
    SocialPlatform.tiktok => 'tiktok',
    SocialPlatform.linkedin => 'linkedin',
    SocialPlatform.facebook => 'facebook',
    SocialPlatform.telegram => 'telegram',
    SocialPlatform.whatsapp => 'whatsapp',
    SocialPlatform.youtube => 'youtube',
    SocialPlatform.twitch => 'twitch',
    SocialPlatform.snapchat => 'snapchat',
    SocialPlatform.website => 'website',
    SocialPlatform.other => 'other',
  };
}

class ContactSocialProfile {
  final SocialPlatform platform;
  final String value;
  final String? label;
  final String? url;

  const ContactSocialProfile({
    required this.platform,
    required this.value,
    this.label,
    this.url,
  });

  factory ContactSocialProfile.fromMap(Map<String, dynamic> map) {
    return ContactSocialProfile(
      platform: socialPlatformFromValue(map['platform'] as String?),
      value: map['value'] as String? ?? '',
      label: map['label'] as String?,
      url: map['url'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'platform': socialPlatformValue(platform),
      'value': value,
      'label': label,
      'url': url,
    };
  }
}

class ContactIdentity {
  final String displayName;
  final String? photoUrl;
  final int? age;
  final DateTime? birthday;
  final String? city;
  final String? company;
  final String? jobTitle;
  final String? bio;
  final String? about;
  final String? favoriteSong;
  final String? email;
  final String? phone;
  final List<ContactSocialProfile> socialProfiles;

  const ContactIdentity({
    required this.displayName,
    this.photoUrl,
    this.age,
    this.birthday,
    this.city,
    this.company,
    this.jobTitle,
    this.bio,
    this.about,
    this.favoriteSong,
    this.email,
    this.phone,
    this.socialProfiles = const [],
  });

  factory ContactIdentity.fromMap(Map<String, dynamic> map) {
    return ContactIdentity(
      displayName: map['display_name'] as String? ?? '',
      photoUrl: map['photo_url'] as String?,
      age: (map['age'] as num?)?.toInt(),
      birthday: (map['birthday'] as Timestamp?)?.toDate(),
      city: map['city'] as String?,
      company: map['company'] as String?,
      jobTitle: map['job_title'] as String?,
      bio: map['bio'] as String?,
      about: map['about'] as String?,
      favoriteSong: map['favorite_song'] as String?,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      socialProfiles: (map['social_profiles'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(
            (item) =>
                ContactSocialProfile.fromMap(Map<String, dynamic>.from(item)),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'display_name': displayName,
      'photo_url': photoUrl,
      'age': age,
      'birthday': birthday == null ? null : Timestamp.fromDate(birthday!),
      'city': city,
      'company': company,
      'job_title': jobTitle,
      'bio': bio,
      'about': about,
      'favorite_song': favoriteSong,
      'email': email,
      'phone': phone,
      'social_profiles': socialProfiles
          .map((profile) => profile.toMap())
          .toList(),
    };
  }
}

class ContactRelationship {
  final String? relationshipType;
  final String? contextNote;
  final String? privateNotes;
  final List<String> interests;
  final List<String> lookingFor;
  final List<String> personalityTags;
  final String? lastInteractionNote;
  final DateTime? lastInteractionAt;
  final bool isFavorite;
  final bool isArchived;
  final String? customDisplayName;

  const ContactRelationship({
    this.relationshipType,
    this.contextNote,
    this.privateNotes,
    this.interests = const [],
    this.lookingFor = const [],
    this.personalityTags = const [],
    this.lastInteractionNote,
    this.lastInteractionAt,
    this.isFavorite = false,
    this.isArchived = false,
    this.customDisplayName,
  });

  factory ContactRelationship.fromMap(Map<String, dynamic> map) {
    return ContactRelationship(
      relationshipType: map['relationship_type'] as String?,
      contextNote: map['context_note'] as String?,
      privateNotes: map['private_notes'] as String?,
      interests: List<String>.from(map['interests'] ?? const []),
      lookingFor: List<String>.from(map['looking_for'] ?? const []),
      personalityTags: List<String>.from(map['personality_tags'] ?? const []),
      lastInteractionNote: map['last_interaction_note'] as String?,
      lastInteractionAt: (map['last_interaction_at'] as Timestamp?)?.toDate(),
      isFavorite: map['is_favorite'] as bool? ?? false,
      isArchived: map['is_archived'] as bool? ?? false,
      customDisplayName: map['custom_display_name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'relationship_type': relationshipType,
      'context_note': contextNote,
      'private_notes': privateNotes,
      'interests': interests,
      'looking_for': lookingFor,
      'personality_tags': personalityTags,
      'last_interaction_note': lastInteractionNote,
      'last_interaction_at': lastInteractionAt == null
          ? null
          : Timestamp.fromDate(lastInteractionAt!),
      'is_favorite': isFavorite,
      'is_archived': isArchived,
      'custom_display_name': customDisplayName,
    };
  }
}

class ContactRecord {
  final String id;
  final String ownerUid;
  final ContactSource source;
  final String? linkedUserUid;
  final String? deviceContactId;
  final String? importedFromQrId;
  final ContactIdentity identity;
  final ContactRelationship relationship;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ContactRecord({
    required this.id,
    required this.ownerUid,
    required this.source,
    required this.identity,
    required this.relationship,
    this.linkedUserUid,
    this.deviceContactId,
    this.importedFromQrId,
    this.createdAt,
    this.updatedAt,
  });

  factory ContactRecord.fromMap(Map<String, dynamic> map, String id) {
    final identityMap = map['identity'] is Map<String, dynamic>
        ? map['identity'] as Map<String, dynamic>
        : _legacyIdentityFromRoot(map);
    final relationshipMap = map['relationship'] is Map<String, dynamic>
        ? map['relationship'] as Map<String, dynamic>
        : _legacyRelationshipFromRoot(map);

    return ContactRecord(
      id: id,
      ownerUid: map['owner_uid'] as String? ?? '',
      source: _contactSourceFromValue(map['source'] as String?),
      linkedUserUid: map['linked_user_uid'] as String?,
      deviceContactId: map['device_contact_id'] as String?,
      importedFromQrId: map['imported_from_qr_id'] as String?,
      identity: ContactIdentity.fromMap(identityMap),
      relationship: ContactRelationship.fromMap(relationshipMap),
      createdAt: (map['created_at'] as Timestamp?)?.toDate(),
      updatedAt: (map['updated_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'owner_uid': ownerUid,
      'source': _contactSourceValue(source),
      'linked_user_uid': linkedUserUid,
      'device_contact_id': deviceContactId,
      'imported_from_qr_id': importedFromQrId,
      'identity': identity.toMap(),
      'relationship': relationship.toMap(),
      'created_at': createdAt ?? FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  // Getters de compatibilidad para no romper el UI actual.
  String get displayName =>
      relationship.customDisplayName?.trim().isNotEmpty == true
      ? relationship.customDisplayName!
      : identity.displayName;
  String? get photoUrl => identity.photoUrl;
  int? get age => identity.age;
  DateTime? get birthday => identity.birthday;
  String? get city => identity.city;
  String? get company => identity.company;
  String? get jobTitle => identity.jobTitle;
  String? get bio => identity.bio;
  String? get about => identity.about;
  String? get favoriteSong => identity.favoriteSong;
  String? get email => identity.email;
  String? get phone => identity.phone;
  List<ContactSocialProfile> get socialProfiles => identity.socialProfiles;
  List<String> get interests => relationship.interests;
  List<String> get lookingFor => relationship.lookingFor;
  List<String> get personalityTags => relationship.personalityTags;
  String? get relationshipContext => relationship.contextNote;
  String? get lastInteractionNote => relationship.lastInteractionNote;
  DateTime? get lastInteractionAt => relationship.lastInteractionAt;
}

Map<String, dynamic> _legacyIdentityFromRoot(Map<String, dynamic> map) {
  return {
    'display_name': map['display_name'],
    'photo_url': map['photo_url'],
    'age': map['age'],
    'birthday': map['birthday'],
    'city': map['city'],
    'company': map['company'],
    'job_title': map['job_title'],
    'bio': map['bio'],
    'about': map['about'],
    'favorite_song': map['favorite_song'],
    'email': map['email'],
    'phone': map['phone'],
    'social_profiles': map['social_profiles'],
  };
}

Map<String, dynamic> _legacyRelationshipFromRoot(Map<String, dynamic> map) {
  return {
    'context_note': map['relationship_context'],
    'private_notes': null,
    'interests': map['interests'],
    'looking_for': map['looking_for'],
    'personality_tags': map['personality_tags'],
    'last_interaction_note': map['last_interaction_note'],
    'last_interaction_at': map['last_interaction_at'],
    'is_favorite': false,
    'is_archived': false,
    'custom_display_name': null,
  };
}

ContactSource _contactSourceFromValue(String? value) {
  switch (value) {
    case 'device_import':
      return ContactSource.deviceImport;
    case 'linked_user':
      return ContactSource.linkedUser;
    case 'qr_import':
      return ContactSource.qrImport;
    default:
      return ContactSource.manual;
  }
}

String _contactSourceValue(ContactSource source) {
  return switch (source) {
    ContactSource.manual => 'manual',
    ContactSource.deviceImport => 'device_import',
    ContactSource.linkedUser => 'linked_user',
    ContactSource.qrImport => 'qr_import',
  };
}
