import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peoplesync/features/navigation/models/menu_option.dart';

class NavigationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtains the role_id from the given user id.
  Future<String?> fetchUserRoleId(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!['rol_id'] as String?;
      } else {
        print(
          'NavigationService.fetchUserRoleId: document for $uid does not exist',
        );
      }
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        print(
          'NavigationService.fetchUserRoleId: PERMISSION DENIED for user $uid. Check Firestore rules.',
        );
      } else {
        print(
          'NavigationService.fetchUserRoleId error: ${e.code} - ${e.message}',
        );
      }
    } catch (e) {
      print('NavigationService.fetchUserRoleId unexpected error: $e');
    }
    return null;
  }

  // Obtains the list of menu ids associated with a given role_id.
  Future<List<String>> fetchRoleMenus(String roleId) async {
    try {
      final doc = await _firestore.collection('rol').doc(roleId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['menus'] is List) {
          return List<String>.from(data['menus']);
        } else {
          print('NavigationService: Role document $roleId has no "menus" list');
        }
      } else {
        print('NavigationService: Role document $roleId not found');
      }
    } on FirebaseException catch (e) {
      print('NavigationService.fetchRoleMenus error: ${e.code} - ${e.message}');
    } catch (e) {
      print('NavigationService.fetchRoleMenus unexpected error: $e');
    }
    return [];
  }

  // Fetches the detailed MenuOption records for the given list of menu ids.
  Future<List<MenuOption>> fetchMenuOptions(List<String> menuIds) async {
    if (menuIds.isEmpty) return [];

    try {
      // If we have more than 10 menus, whereIn fails in Firestore. We assume < 10 for navigation
      final querySnapshot = await _firestore
          .collection('menus')
          .where(FieldPath.documentId, whereIn: menuIds)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print(
          'NavigationService: No documents found in "menus" collection for IDs: $menuIds',
        );
      }

      final options = querySnapshot.docs
          .map((doc) => MenuOption.fromMap(doc.data(), doc.id))
          .toList();

      // Sort them according to the `order` property
      options.sort((a, b) => a.order.compareTo(b.order));

      return options;
    } on FirebaseException catch (e) {
      print(
        'NavigationService.fetchMenuOptions error: ${e.code} - ${e.message}',
      );
    } catch (e) {
      print('NavigationService.fetchMenuOptions unexpected error: $e');
    }
    return [];
  }

  // Convenience method that chains all queries together for a given user id.
  Future<List<MenuOption>> fetchMenusForUser(String uid) async {
    print('NavigationService: Fetching menus for UID: $uid');

    final roleId = await fetchUserRoleId(uid);
    if (roleId == null || roleId.isEmpty) {
      print('NavigationService: No role found for UID $uid');
      return [];
    }
    print('NavigationService: Found role: $roleId');

    final menuIds = await fetchRoleMenus(roleId);
    if (menuIds.isEmpty) {
      print('NavigationService: No menus defined for role $roleId');
      return [];
    }
    print(
      'NavigationService: Found ${menuIds.length} menu IDs for role $roleId: $menuIds',
    );

    final options = await fetchMenuOptions(menuIds);
    print(
      'NavigationService: Successfully fetched ${options.length} menu options',
    );

    return options;
  }
}
