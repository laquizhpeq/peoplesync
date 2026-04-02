import 'package:flutter/material.dart';
import 'package:peoplesync/features/contacts/contact_service.dart';
import 'package:peoplesync/features/contacts/models/contact_record.dart';

class ContactFormViewModel extends ChangeNotifier {
  final ContactService contactService;

  final formKey = GlobalKey<FormState>();
  final displayNameController = TextEditingController();
  final ageController = TextEditingController();
  final cityController = TextEditingController();
  final companyController = TextEditingController();
  final jobTitleController = TextEditingController();
  final bioController = TextEditingController();
  final aboutController = TextEditingController();
  final favoriteSongController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final interestsController = TextEditingController();
  final lookingForController = TextEditingController();
  final personalityTagsController = TextEditingController();
  final relationshipContextController = TextEditingController();
  final lastInteractionNoteController = TextEditingController();

  final List<ContactSocialProfileDraft> socialProfiles = [
    ContactSocialProfileDraft(),
  ];

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  ContactFormViewModel({required this.contactService});

  String? validateRequiredName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Introduce al menos un nombre visible';
    }
    return null;
  }

  void addSocialProfile() {
    socialProfiles.add(ContactSocialProfileDraft());
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

    final profile = socialProfiles.removeAt(index);
    profile.dispose();
    notifyListeners();
  }

  Future<String?> saveContact() async {
    if (!formKey.currentState!.validate()) return 'invalid';

    _isSaving = true;
    notifyListeners();

    try {
      await contactService.createManualContact(
        displayName: displayNameController.text.trim(),
        age: int.tryParse(ageController.text.trim()),
        city: _normalizedText(cityController),
        company: _normalizedText(companyController),
        jobTitle: _normalizedText(jobTitleController),
        bio: _normalizedText(bioController),
        about: _normalizedText(aboutController),
        favoriteSong: _normalizedText(favoriteSongController),
        email: _normalizedText(emailController),
        phone: _normalizedText(phoneController),
        interests: _splitTags(interestsController.text),
        lookingFor: _splitTags(lookingForController.text),
        personalityTags: _splitTags(personalityTagsController.text),
        relationshipContext: _normalizedText(relationshipContextController),
        lastInteractionNote: _normalizedText(lastInteractionNoteController),
        socialProfiles: socialProfiles
            .where((profile) => profile.valueController.text.trim().isNotEmpty)
            .map(
              (profile) => ContactSocialProfile(
                platform: profile.platform,
                value: profile.valueController.text.trim(),
                label: profile.labelController.text.trim().isEmpty
                    ? null
                    : profile.labelController.text.trim(),
                url: profile.urlController.text.trim().isEmpty
                    ? null
                    : profile.urlController.text.trim(),
              ),
            )
            .toList(),
      );

      return null;
    } catch (e) {
      return 'No se pudo guardar el contacto: $e';
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  List<String> _splitTags(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  String? _normalizedText(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  @override
  void dispose() {
    displayNameController.dispose();
    ageController.dispose();
    cityController.dispose();
    companyController.dispose();
    jobTitleController.dispose();
    bioController.dispose();
    aboutController.dispose();
    favoriteSongController.dispose();
    emailController.dispose();
    phoneController.dispose();
    interestsController.dispose();
    lookingForController.dispose();
    personalityTagsController.dispose();
    relationshipContextController.dispose();
    lastInteractionNoteController.dispose();
    for (final social in socialProfiles) {
      social.dispose();
    }
    super.dispose();
  }
}

class ContactSocialProfileDraft {
  SocialPlatform platform;
  final TextEditingController valueController;
  final TextEditingController labelController;
  final TextEditingController urlController;

  ContactSocialProfileDraft({this.platform = SocialPlatform.instagram})
    : valueController = TextEditingController(),
      labelController = TextEditingController(),
      urlController = TextEditingController();

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
