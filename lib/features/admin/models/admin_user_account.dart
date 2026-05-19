import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUserAccount {
  final String uid;
  final String fullName;
  final String email;
  final String rolId;
  final String? photoUrl;
  final String? city;
  final String? bio;
  final bool onboardingCompleted;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLogin;
  final DateTime? deactivatedAt;

  const AdminUserAccount({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.rolId,
    required this.photoUrl,
    required this.city,
    required this.bio,
    required this.onboardingCompleted,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.lastLogin,
    required this.deactivatedAt,
  });

  factory AdminUserAccount.fromMap(Map<String, dynamic> map, String uid) {
    return AdminUserAccount(
      uid: uid,
      fullName: map['full_name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      rolId: map['rol_id'] as String? ?? 'usuario',
      photoUrl: map['photo_url'] as String?,
      city: map['city'] as String?,
      bio: map['bio'] as String?,
      onboardingCompleted: map['onboarding_completed'] as bool? ?? false,
      isActive: map['is_active'] as bool? ?? true,
      createdAt: (map['created_at'] as Timestamp?)?.toDate(),
      updatedAt: (map['updated_at'] as Timestamp?)?.toDate(),
      lastLogin: (map['last_login'] as Timestamp?)?.toDate(),
      deactivatedAt: (map['deactivated_at'] as Timestamp?)?.toDate(),
    );
  }
}
