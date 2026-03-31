import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  String full_name;
  String? email;
  String rol_id;
  DateTime? last_login;

  UserProfile({
    required this.uid,
    this.full_name = '',
    this.email,
    required this.rol_id,
    this.last_login,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: uid,
      full_name: map['full_name'] ?? '',
      email: map['email'],
      rol_id: map['rol_id'] ?? 'user', // Default to basic user role if none
      last_login: map['last_login']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'full_name': full_name,
      'email': email,
      'rol_id': rol_id,
      'last_login': last_login ?? FieldValue.serverTimestamp(),
    };
  }
}
