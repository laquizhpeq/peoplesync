import 'package:cloud_firestore/cloud_firestore.dart';

enum ContactSource { manual, linkedUser, qrImport }

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

class ContactRecord {
  final String id;
  final String ownerUid;
  final ContactSource source;
  final String displayName;
  final String? linkedUserUid;
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
  final List<String> interests;
  final List<String> lookingFor;
  final List<String> personalityTags;
  final String? relationshipContext;
  final String? lastInteractionNote;
  final List<ContactSocialProfile> socialProfiles;
  final String? importedFromQrId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastInteractionAt;

  const ContactRecord({
    required this.id,
    required this.ownerUid,
    required this.source,
    required this.displayName,
    this.linkedUserUid,
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
    this.interests = const [],
    this.lookingFor = const [],
    this.personalityTags = const [],
    this.relationshipContext,
    this.lastInteractionNote,
    this.socialProfiles = const [],
    this.importedFromQrId,
    this.createdAt,
    this.updatedAt,
    this.lastInteractionAt,
  });

  factory ContactRecord.fromMap(Map<String, dynamic> map, String id) {
    return ContactRecord(
      id: id,
      ownerUid: map['owner_uid'] as String? ?? '',
      source: _contactSourceFromValue(map['source'] as String?),
      displayName: map['display_name'] as String? ?? '',
      linkedUserUid: map['linked_user_uid'] as String?,
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
      interests: List<String>.from(map['interests'] ?? const []),
      lookingFor: List<String>.from(map['looking_for'] ?? const []),
      personalityTags: List<String>.from(map['personality_tags'] ?? const []),
      relationshipContext: map['relationship_context'] as String?,
      lastInteractionNote: map['last_interaction_note'] as String?,
      socialProfiles: (map['social_profiles'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(
            (item) =>
                ContactSocialProfile.fromMap(Map<String, dynamic>.from(item)),
          )
          .toList(),
      importedFromQrId: map['imported_from_qr_id'] as String?,
      createdAt: (map['created_at'] as Timestamp?)?.toDate(),
      updatedAt: (map['updated_at'] as Timestamp?)?.toDate(),
      lastInteractionAt: (map['last_interaction_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'owner_uid': ownerUid,
      'source': _contactSourceValue(source),
      'display_name': displayName,
      'linked_user_uid': linkedUserUid,
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
      'interests': interests,
      'looking_for': lookingFor,
      'personality_tags': personalityTags,
      'relationship_context': relationshipContext,
      'last_interaction_note': lastInteractionNote,
      'social_profiles': socialProfiles
          .map((profile) => profile.toMap())
          .toList(),
      'imported_from_qr_id': importedFromQrId,
      'created_at': createdAt ?? FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'last_interaction_at': lastInteractionAt == null
          ? null
          : Timestamp.fromDate(lastInteractionAt!),
    };
  }
}

ContactSource _contactSourceFromValue(String? value) {
  switch (value) {
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
    ContactSource.linkedUser => 'linked_user',
    ContactSource.qrImport => 'qr_import',
  };
}
