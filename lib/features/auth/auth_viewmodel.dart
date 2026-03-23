import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService authService;

  AuthViewModel({required this.authService});

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
      // Login success: clear error and notify
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      debugPrint('AuthViewModel: login success');
    } catch (e) {
      _isLoading = false;
      // Extract message from Exception if present
      final errorStr = e.toString();
      _errorMessage = errorStr.startsWith('Exception: ')
          ? errorStr.substring(11)
          : errorStr;
      notifyListeners();
      debugPrint('AuthViewModel: login error: $_errorMessage');
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
