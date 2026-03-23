import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'models/user_profile.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Reference to the current user's document
  DocumentReference get _userDoc =>
      _firestore.collection('users').doc(_auth.currentUser?.uid);

  // Stream of profile updates
  Stream<UserProfile?> get profileStream {
    return _userDoc.snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>;
      return UserProfile.fromMap(data, doc.id);
    });
  }

  // Get profile once
  Future<UserProfile?> getProfile() async {
    final doc = await _userDoc.get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile.fromMap(data, doc.id);
  }

  // Update profile fields
  Future<void> updateProfile({
    String? displayName,
    String? phoneNumber,
    String? bio,
  }) async {
    final data = <String, dynamic>{};
    if (displayName != null) data['displayName'] = displayName;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (bio != null) data['bio'] = bio;
    data['updatedAt'] = FieldValue.serverTimestamp();

    await _userDoc.update(data);
  }

  // Update profile picture (upload to storage and save URL)
  Future<void> updatePhotoUrl(String filePath) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Usuario no autenticado');

    final ref = _storage.ref().child('profile_photos').child('$uid.jpg');

    final uploadTask = ref.putFile(File(filePath));
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();

    await _userDoc.update({
      'photoUrl': downloadUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
