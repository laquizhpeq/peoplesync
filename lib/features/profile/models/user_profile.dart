import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  String displayName;
  String? email;
  String? photoUrl;
  String? phoneNumber;
  String? bio;
  DateTime? createdAt;
  DateTime? updatedAt;

  UserProfile({
    required this.uid,
    this.displayName = '',
    this.email,
    this.photoUrl,
    this.phoneNumber,
    this.bio,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: uid,
      displayName: map['displayName'] ?? '',
      email: map['email'],
      photoUrl: map['photoUrl'],
      phoneNumber: map['phoneNumber'],
      bio: map['bio'],
      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
