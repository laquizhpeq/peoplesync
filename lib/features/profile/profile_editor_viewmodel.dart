import 'package:flutter/material.dart';
import 'package:peoplesync/features/contacts/models/contact_record.dart';
import 'package:peoplesync/features/profile/models/user_profile.dart';
import 'package:peoplesync/features/profile/profile_service.dart';

class ProfileEditorViewModel extends ChangeNotifier {
  final ProfileService profileService;
  final bool markOnboardingCompleteOnSave;

  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final photoUrlController = TextEditingController();
  final cityController = TextEditingController();
  final bioController = TextEditingController();

  final List<ProfileSocialProfileDraft> socialProfiles = [
    ProfileSocialProfileDraft(),
  ];

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  UserProfile? _profile;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  UserProfile? get profile => _profile;

  ProfileEditorViewModel({
    required this.profileService,
    this.markOnboardingCompleteOnSave = false,
  }) {
    _loadProfile();
  }

  String? validateRequiredName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Introduce tu nombre visible';
    }
    if (value.trim().length < 2) {
      return 'El nombre es demasiado corto';
    }
    return null;
  }

  Future<void> _loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await profileService.getProfile(forceRefresh: true);
      _hydrateControllers(_profile);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addSocialProfile() {
    socialProfiles.add(ProfileSocialProfileDraft());
    notifyListeners();
  }

  void updateSocialPlatform(int index, SocialPlatform platform) {
    socialProfiles[index].platform = platform;
    notifyListeners();
  }

  void removeSocialProfile(int index) {
    if (socialProfiles.length == 1) {
      socialProfiles[index].clear();
      notifyListeners();
      return;
    }

    final draft = socialProfiles.removeAt(index);
    draft.dispose();
    notifyListeners();
  }

  Future<bool> save() async {
    if (!formKey.currentState!.validate()) return false;

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await profileService.saveProfile(
        fullName: fullNameController.text.trim(),
        photoUrl: _normalizedText(photoUrlController),
        city: _normalizedText(cityController),
        bio: _normalizedText(bioController),
        socialProfiles: _buildSocialProfiles(),
        onboardingCompleted: markOnboardingCompleteOnSave ? true : null,
      );
      _profile = await profileService.getProfile(forceRefresh: true);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void _hydrateControllers(UserProfile? profile) {
    fullNameController.text = profile?.fullName ?? '';
    photoUrlController.text = profile?.photoUrl ?? '';
    cityController.text = profile?.city ?? '';
    bioController.text = profile?.bio ?? '';

    for (final draft in socialProfiles) {
      draft.dispose();
    }
    socialProfiles.clear();

    final profiles = profile?.socialProfiles ?? const <ContactSocialProfile>[];
    if (profiles.isEmpty) {
      socialProfiles.add(ProfileSocialProfileDraft());
      return;
    }

    socialProfiles.addAll(
      profiles.map(
        (profile) => ProfileSocialProfileDraft.fromProfile(profile),
      ),
    );
  }

  List<ContactSocialProfile> _buildSocialProfiles() {
    return socialProfiles
        .where((draft) => draft.valueController.text.trim().isNotEmpty)
        .map(
          (draft) => ContactSocialProfile(
            platform: draft.platform,
            value: draft.valueController.text.trim(),
            label: _normalizedText(draft.labelController),
            url: _normalizedText(draft.urlController),
          ),
        )
        .toList();
  }

  String? _normalizedText(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  @override
  void dispose() {
    fullNameController.dispose();
    photoUrlController.dispose();
    cityController.dispose();
    bioController.dispose();
    for (final draft in socialProfiles) {
      draft.dispose();
    }
    super.dispose();
  }
}

class ProfileSocialProfileDraft {
  SocialPlatform platform;
  final TextEditingController valueController;
  final TextEditingController labelController;
  final TextEditingController urlController;

  ProfileSocialProfileDraft({this.platform = SocialPlatform.instagram})
    : valueController = TextEditingController(),
      labelController = TextEditingController(),
      urlController = TextEditingController();

  ProfileSocialProfileDraft.fromProfile(ContactSocialProfile profile)
    : platform = profile.platform,
      valueController = TextEditingController(text: profile.value),
      labelController = TextEditingController(text: profile.label ?? ''),
      urlController = TextEditingController(text: profile.url ?? '');

  void clear() {
    platform = SocialPlatform.instagram;
    valueController.clear();
    labelController.clear();
    urlController.clear();
  }

  void dispose() {
    valueController.dispose();
    labelController.dispose();
    urlController.dispose();
  }
}
