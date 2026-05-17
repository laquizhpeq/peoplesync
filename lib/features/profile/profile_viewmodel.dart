import 'package:flutter/material.dart';
import 'package:peoplesync/core/services/app_error_mapper.dart';
import 'profile_service.dart';
import 'package:peoplesync/features/profile/models/user_profile.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileService profileService;

  UserProfile? _profile;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  ProfileViewModel({required this.profileService}) {
    _loadProfile();
  }

  Future<void> reload() => _loadProfile();

  Future<void> _loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _profile = await profileService.getProfile(forceRefresh: true);
    } catch (e) {
      _errorMessage = AppErrorMapper.toUserMessage(
        e,
        fallback: 'No se pudo cargar tu perfil. Reintenta en unos segundos.',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({required String fullName}) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await profileService.updateProfile(fullName: fullName);
      _profile = await profileService.getProfile(forceRefresh: true);
    } catch (e) {
      _errorMessage = AppErrorMapper.toUserMessage(
        e,
        fallback: 'No se pudo actualizar tu perfil. Vuelve a intentarlo.',
      );
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
