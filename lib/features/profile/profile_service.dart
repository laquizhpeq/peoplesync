import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:peoplesync/features/contacts/models/contact_record.dart';
import 'models/user_profile.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserProfile? _cachedProfile;
  String? _cachedUid;

  // Reference to the current user's document
  DocumentReference get _userDoc =>
      _firestore.collection('users').doc(_auth.currentUser?.uid);

  // Stream of profile updates
  Stream<UserProfile?> get profileStream {
    return _userDoc.snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>;
      final profile = UserProfile.fromMap(data, doc.id);
      _cachedUid = doc.id;
      _cachedProfile = profile;
      return profile;
    });
  }

  // Get profile once
  Future<UserProfile?> getProfile({bool forceRefresh = false}) async {
    final uid = _auth.currentUser?.uid;
    if (!forceRefresh &&
        uid != null &&
        _cachedUid == uid &&
        _cachedProfile != null) {
      return _cachedProfile;
    }

    final doc = await _userDoc.get();
    if (!doc.exists) {
      _cachedProfile = null;
      _cachedUid = uid;
      return null;
    }
    final data = doc.data() as Map<String, dynamic>;
    final profile = UserProfile.fromMap(data, doc.id);
    _cachedUid = doc.id;
    _cachedProfile = profile;
    return profile;
  }

  // Get external profile (for importing via QR)
  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      return null;
    }
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
      'photo_url': null,
      'city': null,
      'bio': null,
      'social_profiles': const [],
      'onboarding_completed': false,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'last_login': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    _cachedProfile = null;
    _cachedUid = uid;
  }

  Future<void> ensureCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No hay un usuario autenticado');
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      await createInitialProfile(
        uid: user.uid,
        email: user.email ?? '',
        fullName: user.displayName ?? '',
      );
    }
  }

  Future<bool> requiresOnboarding() async {
    final profile = await getProfile();
    if (profile == null) return true;
    if (!profile.onboardingCompleted) return true;
    return profile.fullName.trim().isEmpty;
  }

  Future<void> saveProfile({
    required String fullName,
    String? photoUrl,
    String? city,
    String? bio,
    List<ContactSocialProfile> socialProfiles = const [],
    bool? onboardingCompleted,
  }) async {
    final data = <String, dynamic>{
      'full_name': fullName,
      'photo_url': photoUrl,
      'city': city,
      'bio': bio,
      'social_profiles': socialProfiles
          .map((profile) => profile.toMap())
          .toList(),
      'updated_at': FieldValue.serverTimestamp(),
    };

    if (onboardingCompleted != null) {
      data['onboarding_completed'] = onboardingCompleted;
    }

    await _userDoc.set(data, SetOptions(merge: true));
    _cachedProfile = null;
  }

  Future<void> touchLastLogin() async {
    await _userDoc.set({
      'last_login': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    _cachedProfile = null;
  }

  Future<void> updateProfile({
    required String fullName,
    String? photoUrl,
    String? city,
    String? bio,
    List<ContactSocialProfile> socialProfiles = const [],
  }) async {
    await saveProfile(
      fullName: fullName,
      photoUrl: photoUrl,
      city: city,
      bio: bio,
      socialProfiles: socialProfiles,
    );
  }
}
