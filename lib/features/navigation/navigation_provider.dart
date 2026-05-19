import 'package:flutter/foundation.dart';
import 'package:peoplesync/features/navigation/models/menu_option.dart';
import 'package:peoplesync/features/navigation/navigation_service.dart';
import 'package:peoplesync/core/utils/route_utils.dart';

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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _menus = await navigationService.fetchMenusForUser(uid);
      _hasLoaded = true;
    } catch (e) {
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

  bool isAuthorized(String path) {
    final normalizedPath = normalizeAppRoute(path);

    if (normalizedPath == '/login') return true;
    if (normalizedPath == '/contacts/new') return true;
    if (normalizedPath == '/profile/edit') return true;
    if (normalizedPath == '/contact-sync') return true;
    if (normalizedPath == '/settings') return true;
    if (normalizedPath == '/assistant') return true;
    if (path.toLowerCase().startsWith('/connections/')) return true;
    if (path.toLowerCase().startsWith('/contacts/')) return true;
    for (var m in _menus) {
      if (isSameAppRoute(m.route, normalizedPath)) return true;
    }
    if (normalizedPath == '/' || normalizedPath == '/home') return true;

    return false;
  }
}
