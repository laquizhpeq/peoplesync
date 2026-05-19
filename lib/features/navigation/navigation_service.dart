import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peoplesync/features/navigation/models/menu_option.dart';

class NavigationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> fetchUserRoleId(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!['rol_id'] as String?;
      }
    } on FirebaseException {
      return null;
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<List<String>> fetchRoleMenus(String roleId) async {
    try {
      final doc = await _firestore.collection('rol').doc(roleId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['menus'] is List) {
          return List<String>.from(data['menus']);
        }
      }
    } on FirebaseException {
      return [];
    } catch (_) {
      return [];
    }
    return [];
  }

  Future<List<MenuOption>> fetchMenuOptions(List<String> menuIds) async {
    if (menuIds.isEmpty) return [];

    try {
      final querySnapshot = await _firestore
          .collection('menus')
          .where(FieldPath.documentId, whereIn: menuIds)
          .get();

      final options = querySnapshot.docs
          .map((doc) => MenuOption.fromMap(doc.data(), doc.id))
          .toList();

      options.sort((a, b) => a.order.compareTo(b.order));

      return options;
    } on FirebaseException {
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<List<MenuOption>> fetchMenusForUser(String uid) async {
    final roleId = await fetchUserRoleId(uid);
    if (roleId == null || roleId.isEmpty) {
      return [];
    }

    final menuIds = await fetchRoleMenus(roleId);
    if (menuIds.isEmpty) {
      return [];
    }

    return fetchMenuOptions(menuIds);
  }
}
