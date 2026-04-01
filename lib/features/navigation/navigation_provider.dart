import 'package:flutter/foundation.dart';
import 'package:peoplesync/features/navigation/models/menu_option.dart';
import 'package:peoplesync/features/navigation/navigation_service.dart';

class NavigationProvider extends ChangeNotifier {
  final NavigationService navigationService;

  List<MenuOption> _menus = [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;

  NavigationProvider({required this.navigationService});

  List<MenuOption> get menus => _menus;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get errorMessage => _errorMessage;

  Future<void> loadMenus(String uid) async {
    print('NavigationProvider: Starting loadMenus for $uid');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _menus = await navigationService.fetchMenusForUser(uid);
      _hasLoaded = true;

      print('NavigationProvider: Successfully loaded ${_menus.length} menus');
    } catch (e) {
      print('NavigationProvider: Error loading menus: $e');
      _errorMessage = 'Error loading menus: $e';
      _hasLoaded = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearMenus() {
    _menus = [];
    _errorMessage = null;
    _isLoading = false;
    _hasLoaded = false;
    notifyListeners();
  }

  // Helper method to check if a user is authorized for a specific route.
  // Exception: the base home route '/' may be globally allowed, or mapped as well based on roles.
  bool isAuthorized(String path) {
    if (path == '/login') return true; // Login is public
    // Allow root / or check if registered in the fetched DB route.
    // If your app routes strictly base authorization on the exact string:
    for (var m in _menus) {
      if (m.route == path) return true;
    }
    // Alternatively, if Home is always accessible to authenticated users:
    if (path == '/' || path == '/home') return true;

    return false;
  }
}
