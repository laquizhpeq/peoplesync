import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  String fullName;
  String? email;
  String rolId;
  DateTime? lastLogin;

  UserProfile({
    required this.uid,
    this.fullName = '',
    this.email,
    required this.rolId,
    this.lastLogin,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: uid,
      fullName: map['full_name'] ?? '',
      email: map['email'],
      rolId:
          map['rol_id'] ?? 'usuario', // Default to basic user role if none
      lastLogin: map['last_login']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'full_name': fullName,
      'email': email,
      'rol_id': rolId,
      'last_login': lastLogin ?? FieldValue.serverTimestamp(),
    };
  }
}
