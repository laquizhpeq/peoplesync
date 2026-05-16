import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peoplesync/core/services/app_logger.dart';
import 'package:peoplesync/features/admin/models/admin_user_account.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  Future<List<String>> fetchAvailableRoles() async {
    try {
      final snapshot = await _firestore.collection('rol').get();
      final roles = snapshot.docs.map((doc) => doc.id).toList()..sort();
      if (roles.isEmpty) return const ['usuario', 'admin'];
      return roles;
    } catch (error, stackTrace) {
      AppLogger.error(
        'No se pudieron cargar los roles disponibles',
        scope: 'admin',
        error: error,
        stackTrace: stackTrace,
      );
      return const ['usuario', 'admin'];
    }
  }

  Stream<List<AdminUserAccount>> streamUsers() {
    return _usersCollection.snapshots().map((snapshot) {
      final users = snapshot.docs
          .map((doc) => AdminUserAccount.fromMap(doc.data(), doc.id))
          .toList();
      users.sort((a, b) {
        final aDate =
            a.updatedAt ?? a.lastLogin ?? a.createdAt ?? DateTime(2000);
        final bDate =
            b.updatedAt ?? b.lastLogin ?? b.createdAt ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });
      return users;
    });
  }

  Future<void> updateUser({
    required String uid,
    required String fullName,
    required String email,
    required String rolId,
    String? city,
    String? bio,
    bool? onboardingCompleted,
  }) async {
    await _usersCollection.doc(uid).set({
      'full_name': fullName.trim(),
      'email': email.trim(),
      'rol_id': rolId.trim(),
      'city': _normalize(city),
      'bio': _normalize(bio),
      if (onboardingCompleted != null)
        'onboarding_completed': onboardingCompleted,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> setUserActiveStatus({
    required String uid,
    required bool isActive,
  }) async {
    await _usersCollection.doc(uid).set({
      'is_active': isActive,
      'deactivated_at': isActive ? null : FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> resetOnboarding(String uid) async {
    await _usersCollection.doc(uid).set({
      'onboarding_completed': false,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> softDeleteUser(String uid) async {
    await _usersCollection.doc(uid).set({
      'is_active': false,
      'deactivated_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  String? _normalize(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
