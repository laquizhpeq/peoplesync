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
  String? favoriteSong;
  List<String> affinities;
  List<ContactSocialProfile> socialProfiles;
  bool onboardingCompleted;
  bool isActive;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? lastLogin;
  DateTime? deactivatedAt;

  UserProfile({
    required this.uid,
    this.fullName = '',
    this.email,
    required this.rolId,
    this.photoUrl,
    this.city,
    this.bio,
    this.favoriteSong,
    this.affinities = const [],
    this.socialProfiles = const [],
    this.onboardingCompleted = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.lastLogin,
    this.deactivatedAt,
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
      favoriteSong: map['favorite_song'] as String?,
      affinities: List<String>.from(map['affinities'] ?? const []),
      socialProfiles: (map['social_profiles'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(
            (item) =>
                ContactSocialProfile.fromMap(Map<String, dynamic>.from(item)),
          )
          .toList(),
      onboardingCompleted: map['onboarding_completed'] as bool? ?? false,
      isActive: map['is_active'] as bool? ?? true,
      createdAt: (map['created_at'] as Timestamp?)?.toDate(),
      updatedAt: (map['updated_at'] as Timestamp?)?.toDate(),
      lastLogin: (map['last_login'] as Timestamp?)?.toDate(),
      deactivatedAt: (map['deactivated_at'] as Timestamp?)?.toDate(),
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
      'favorite_song': favoriteSong,
      'affinities': affinities,
      'social_profiles': socialProfiles
          .map((profile) => profile.toMap())
          .toList(),
      'onboarding_completed': onboardingCompleted,
      'is_active': isActive,
      'created_at': createdAt ?? FieldValue.serverTimestamp(),
      'updated_at': updatedAt ?? FieldValue.serverTimestamp(),
      'last_login': lastLogin ?? FieldValue.serverTimestamp(),
      'deactivated_at': deactivatedAt == null
          ? null
          : Timestamp.fromDate(deactivatedAt!),
    };
  }
}
