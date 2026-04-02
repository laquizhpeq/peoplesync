import 'package:cloud_firestore/cloud_firestore.dart';

enum ContactSource { manual, linkedUser }

class ContactRecord {
  final String id;
  final String ownerUid;
  final ContactSource source;
  final String displayName;
  final String? linkedUserUid;
  final String? photoUrl;
  final String? email;
  final String? phone;
  final String? city;
  final String? company;
  final String? jobTitle;
  final String? bio;
  final String? favoriteSong;
  final List<String> interests;
  final List<String> tags;
  final String? contextNote;
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
    this.email,
    this.phone,
    this.city,
    this.company,
    this.jobTitle,
    this.bio,
    this.favoriteSong,
    this.interests = const [],
    this.tags = const [],
    this.contextNote,
    this.createdAt,
    this.updatedAt,
    this.lastInteractionAt,
  });

  factory ContactRecord.fromMap(Map<String, dynamic> map, String id) {
    return ContactRecord(
      id: id,
      ownerUid: map['owner_uid'] ?? '',
      source: map['source'] == 'linked_user'
          ? ContactSource.linkedUser
          : ContactSource.manual,
      displayName: map['display_name'] ?? '',
      linkedUserUid: map['linked_user_uid'],
      photoUrl: map['photo_url'],
      email: map['email'],
      phone: map['phone'],
      city: map['city'],
      company: map['company'],
      jobTitle: map['job_title'],
      bio: map['bio'],
      favoriteSong: map['favorite_song'],
      interests: List<String>.from(map['interests'] ?? const []),
      tags: List<String>.from(map['tags'] ?? const []),
      contextNote: map['context_note'],
      createdAt: (map['created_at'] as Timestamp?)?.toDate(),
      updatedAt: (map['updated_at'] as Timestamp?)?.toDate(),
      lastInteractionAt: (map['last_interaction_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'owner_uid': ownerUid,
      'source': source == ContactSource.linkedUser ? 'linked_user' : 'manual',
      'display_name': displayName,
      'linked_user_uid': linkedUserUid,
      'photo_url': photoUrl,
      'email': email,
      'phone': phone,
      'city': city,
      'company': company,
      'job_title': jobTitle,
      'bio': bio,
      'favorite_song': favoriteSong,
      'interests': interests,
      'tags': tags,
      'context_note': contextNote,
      'created_at': createdAt ?? FieldValue.serverTimestamp(),
      'updated_at': updatedAt ?? FieldValue.serverTimestamp(),
      'last_interaction_at': lastInteractionAt == null
          ? null
          : Timestamp.fromDate(lastInteractionAt!),
    };
  }
}
