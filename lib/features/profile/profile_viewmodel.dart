import 'package:flutter/material.dart';
import 'profile_service.dart';
import 'package:peoplesync/features/profile/models/user_profile.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileService profileService;

  UserProfile? _profile;
  bool _isLoading = true;
  String? _errorMessage;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ProfileViewModel({required this.profileService}) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      _profile = await profileService.getProfile();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({String? fullName}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await profileService.updateProfile(fullName: fullName);
      await _loadProfile(); // refresh
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
