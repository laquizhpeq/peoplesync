import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  String fullName;
  String? email;
  String rolId;
  String? photoUrl;
  DateTime? createdAt;
  DateTime? lastLogin;

  UserProfile({
    required this.uid,
    this.fullName = '',
    this.email,
    required this.rolId,
    this.photoUrl,
    this.createdAt,
    this.lastLogin,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: uid,
      fullName: map['full_name'] ?? '',
      email: map['email'],
      rolId: map['rol_id'] ?? 'usuario',
      photoUrl: map['photo_url'],
      createdAt: (map['created_at'] as Timestamp?)?.toDate(),
      lastLogin: (map['last_login'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'full_name': fullName,
      'email': email,
      'rol_id': rolId,
      'photo_url': photoUrl,
      'created_at': createdAt ?? FieldValue.serverTimestamp(),
      'last_login': lastLogin ?? FieldValue.serverTimestamp(),
    };
  }
}
