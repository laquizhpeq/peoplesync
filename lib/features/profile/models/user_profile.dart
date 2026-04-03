import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peoplesync/features/contacts/models/contact_record.dart';

class UserProfile {
  final String uid;
  String fullName;
  String? email;
  String rolId;
  String? photoUrl;
  String? city;
  String? bio;
  List<ContactSocialProfile> socialProfiles;
  bool onboardingCompleted;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? lastLogin;

  UserProfile({
    required this.uid,
    this.fullName = '',
    this.email,
    required this.rolId,
    this.photoUrl,
    this.city,
    this.bio,
    this.socialProfiles = const [],
    this.onboardingCompleted = false,
    this.createdAt,
    this.updatedAt,
    this.lastLogin,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: uid,
      fullName: map['full_name'] ?? '',
      email: map['email'],
      rolId: map['rol_id'] ?? 'usuario',
      photoUrl: map['photo_url'],
      city: map['city'],
      bio: map['bio'],
      socialProfiles: (map['social_profiles'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(
            (item) =>
                ContactSocialProfile.fromMap(Map<String, dynamic>.from(item)),
          )
          .toList(),
      onboardingCompleted: map['onboarding_completed'] as bool? ?? false,
      createdAt: (map['created_at'] as Timestamp?)?.toDate(),
      updatedAt: (map['updated_at'] as Timestamp?)?.toDate(),
      lastLogin: (map['last_login'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'full_name': fullName,
      'email': email,
      'rol_id': rolId,
      'photo_url': photoUrl,
      'city': city,
      'bio': bio,
      'social_profiles': socialProfiles
          .map((profile) => profile.toMap())
          .toList(),
      'onboarding_completed': onboardingCompleted,
      'created_at': createdAt ?? FieldValue.serverTimestamp(),
      'updated_at': updatedAt ?? FieldValue.serverTimestamp(),
      'last_login': lastLogin ?? FieldValue.serverTimestamp(),
    };
  }
}
