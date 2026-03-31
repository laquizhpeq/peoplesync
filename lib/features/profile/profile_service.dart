import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/user_profile.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
  Future<void> updateProfile({String? full_name}) async {
    final data = <String, dynamic>{};
    if (full_name != null) data['full_name'] = full_name;

    await _userDoc.update(data);
  }
}
