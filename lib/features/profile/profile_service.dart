import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:peoplesync/core/config/env_config.dart';
import 'package:peoplesync/features/contacts/models/contact_record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/user_profile.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserProfile? _cachedProfile;
  String? _cachedUid;

  DocumentReference get _userDoc =>
      _firestore.collection('users').doc(_auth.currentUser?.uid);

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

  UserProfile? get cachedProfile {
    final uid = _auth.currentUser?.uid;
    if (uid == null || _cachedUid != uid) return null;
    return _cachedProfile;
  }

  bool get hasCachedCurrentUserProfile => cachedProfile != null;

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
    final now = DateTime.now();
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
    _cachedUid = uid;
    _cachedProfile = UserProfile(
      uid: uid,
      fullName: fullName,
      email: email,
      rolId: roleId,
      photoUrl: null,
      city: null,
      bio: null,
      socialProfiles: const [],
      onboardingCompleted: false,
      createdAt: now,
      updatedAt: now,
      lastLogin: now,
    );
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
      return;
    }

    final data = doc.data() as Map<String, dynamic>;
    _cachedUid = doc.id;
    _cachedProfile = UserProfile.fromMap(data, doc.id);
  }

  Future<bool> requiresOnboarding() async {
    final profile = await getProfile();
    if (profile == null) return true;
    if (!profile.onboardingCompleted) return true;
    return profile.fullName.trim().isEmpty;
  }

  bool? requiresOnboardingFromCache() {
    final profile = cachedProfile;
    if (profile == null) return null;
    if (!profile.onboardingCompleted) return true;
    return profile.fullName.trim().isEmpty;
  }

  Future<String> uploadProfilePhoto({required Uint8List bytes}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw Exception('No hay un usuario autenticado');
    }

    final bucket = EnvConfig.supabaseContactPhotosBucket;
    final folder = EnvConfig.supabaseProfilePhotosFolder;

    if (EnvConfig.supabaseUrl.isEmpty || EnvConfig.supabaseAnonKey.isEmpty) {
      throw Exception('Supabase no esta configurado en .env.');
    }
    if (bucket.isEmpty) {
      throw Exception('Falta SUPABASE_CONTACT_PHOTOS_BUCKET en .env.');
    }

    final storage = Supabase.instance.client.storage.from(bucket);
    final filePath =
        '$folder/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg';

    await storage.uploadBinary(
      filePath,
      bytes,
      fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
    );

    return storage.getPublicUrl(filePath);
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

  void clearCache() {
    _cachedProfile = null;
    _cachedUid = null;
  }
}
