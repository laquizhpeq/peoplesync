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

  Future<void> createInitialProfile({
    required String uid,
    required String email,
    required String fullName,
    String roleId = 'usuario',
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'full_name': fullName,
      'email': email,
      'rol_id': roleId,
      'last_login': FieldValue.serverTimestamp(),
    });
  }

  // Update profile fields
  Future<void> updateProfile({String? fullName}) async {
    final data = <String, dynamic>{};
    if (fullName != null) data['full_name'] = fullName;

    await _userDoc.update(data);
  }
}
