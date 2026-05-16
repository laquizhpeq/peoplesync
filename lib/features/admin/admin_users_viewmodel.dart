import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:peoplesync/core/services/app_logger.dart';
import 'package:peoplesync/features/admin/admin_service.dart';
import 'package:peoplesync/features/admin/models/admin_user_account.dart';

enum AdminUsersFilter { all, active, inactive, admins }

class AdminUsersViewModel extends ChangeNotifier {
  final AdminService adminService;

  List<AdminUserAccount> _users = [];
  List<String> _roles = const ['usuario', 'admin'];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  String _query = '';
  AdminUsersFilter _filter = AdminUsersFilter.all;
  StreamSubscription<List<AdminUserAccount>>? _subscription;

  List<AdminUserAccount> get users => _applyFilters(_users);
  List<AdminUserAccount> get allUsers => _users;
  List<String> get roles => _roles;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String get query => _query;
  AdminUsersFilter get filter => _filter;

  AdminUsersViewModel({required this.adminService}) {
    initialize();
  }

  Future<void> initialize() async {
    AppLogger.info('Inicializando panel de admin', scope: 'admin');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _roles = await adminService.fetchAvailableRoles();
      _subscription?.cancel();
      _subscription = adminService.streamUsers().listen(
        (users) {
          _users = users;
          _isLoading = false;
          _errorMessage = null;
          AppLogger.debug(
            'Usuarios visibles en panel admin: ${users.length}',
            scope: 'admin',
          );
          notifyListeners();
        },
        onError: (error) {
          _isLoading = false;
          _errorMessage = 'No se pudo cargar la lista de usuarios.';
          AppLogger.error(
            'Fallo el stream de usuarios del panel admin',
            scope: 'admin',
            error: error,
          );
          notifyListeners();
        },
      );
    } catch (error, stackTrace) {
      _isLoading = false;
      _errorMessage = 'No se pudo iniciar el panel de administracion.';
      AppLogger.error(
        'Fallo la inicializacion del panel admin',
        scope: 'admin',
        error: error,
        stackTrace: stackTrace,
      );
      notifyListeners();
    }
  }

  void setQuery(String value) {
    _query = value.trim().toLowerCase();
    notifyListeners();
  }

  void setFilter(AdminUsersFilter value) {
    if (_filter == value) return;
    _filter = value;
    notifyListeners();
  }

  Future<String?> updateUser({
    required String uid,
    required String fullName,
    required String email,
    required String rolId,
    String? city,
    String? bio,
    bool? onboardingCompleted,
  }) async {
    return _runAdminAction(() async {
      await adminService.updateUser(
        uid: uid,
        fullName: fullName,
        email: email,
        rolId: rolId,
        city: city,
        bio: bio,
        onboardingCompleted: onboardingCompleted,
      );
    }, failureMessage: 'No se pudo actualizar el usuario.');
  }

  Future<String?> setUserActiveStatus({
    required String uid,
    required bool isActive,
  }) async {
    return _runAdminAction(() async {
      await adminService.setUserActiveStatus(uid: uid, isActive: isActive);
    }, failureMessage: 'No se pudo cambiar el estado del usuario.');
  }

  Future<String?> resetOnboarding(String uid) async {
    return _runAdminAction(() async {
      await adminService.resetOnboarding(uid);
    }, failureMessage: 'No se pudo reiniciar el onboarding.');
  }

  Future<String?> softDeleteUser(String uid) async {
    return _runAdminAction(() async {
      await adminService.softDeleteUser(uid);
    }, failureMessage: 'No se pudo dar de baja al usuario.');
  }

  List<AdminUserAccount> _applyFilters(List<AdminUserAccount> source) {
    final filtered = source.where((user) {
      if (_query.isNotEmpty) {
        final haystack = [
          user.fullName,
          user.email,
          user.rolId,
          user.city,
        ].whereType<String>().join(' ').toLowerCase();
        if (!haystack.contains(_query)) return false;
      }

      return switch (_filter) {
        AdminUsersFilter.all => true,
        AdminUsersFilter.active => user.isActive,
        AdminUsersFilter.inactive => !user.isActive,
        AdminUsersFilter.admins => user.rolId.toLowerCase() == 'admin',
      };
    }).toList();

    filtered.sort((a, b) {
      final aDate = a.updatedAt ?? a.lastLogin ?? a.createdAt ?? DateTime(2000);
      final bDate = b.updatedAt ?? b.lastLogin ?? b.createdAt ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });
    return filtered;
  }

  Future<String?> _runAdminAction(
    Future<void> Function() action, {
    required String failureMessage,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      return null;
    } catch (error, stackTrace) {
      AppLogger.error(
        failureMessage,
        scope: 'admin',
        error: error,
        stackTrace: stackTrace,
      );
      return failureMessage;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
