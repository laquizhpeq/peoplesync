import 'package:flutter/material.dart';
import 'package:peoplesync/core/services/app_error_mapper.dart';
import 'package:peoplesync/core/services/app_logger.dart';
import 'package:peoplesync/features/navigation/navigation_provider.dart';
import 'package:peoplesync/features/profile/profile_service.dart';
import 'auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService authService;
  final ProfileService profileService;
  final NavigationProvider navigationProvider;

  AuthViewModel({
    required this.authService,
    required this.profileService,
    required this.navigationProvider,
  });

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _finalizeAuthenticatedSession();
    } catch (e) {
      _isLoading = false;
      AppLogger.error('Fallo el login de usuario', scope: 'auth', error: e);
      _errorMessage = AppErrorMapper.toUserMessage(
        e,
        fallback: 'No se pudo iniciar sesion. Vuelve a intentarlo.',
      );
      notifyListeners();
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('No se pudo crear el usuario');
      }

      await profileService.createInitialProfile(
        uid: user.uid,
        email: email,
        fullName: fullName,
        roleId: 'usuario',
      );

      await navigationProvider.loadMenus(user.uid);

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = AppErrorMapper.toUserMessage(
        e,
        fallback:
            'No se pudo crear la cuenta. Revisa tus datos y prueba otra vez.',
      );
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await authService.signOut();
    navigationProvider.clearMenus();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _finalizeAuthenticatedSession() async {
    final uid = authService.currentUser?.uid;
    if (uid != null) {
      await profileService.ensureCurrentUserProfile();
      final profile = profileService.cachedProfile;
      if (profile != null && !profile.isActive) {
        await authService.signOut();
        throw Exception(
          'Tu cuenta esta desactivada. Contacta con un administrador.',
        );
      }
      await profileService.touchLastLogin();
      await navigationProvider.loadMenus(uid);
    }

    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
