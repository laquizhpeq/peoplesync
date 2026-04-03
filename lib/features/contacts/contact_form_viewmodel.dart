import 'package:flutter/material.dart';
import 'package:peoplesync/features/contacts/contact_service.dart';
import 'package:peoplesync/features/contacts/models/contact_record.dart';

class ContactFormViewModel extends ChangeNotifier {
  final ContactService contactService;

  final formKey = GlobalKey<FormState>();
  final identityDisplayNameController = TextEditingController();
  final identityAgeController = TextEditingController();
  final identityCityController = TextEditingController();
  final identityCompanyController = TextEditingController();
  final identityJobTitleController = TextEditingController();
  final identityBioController = TextEditingController();
  final identityAboutController = TextEditingController();
  final identityFavoriteSongController = TextEditingController();
  final identityEmailController = TextEditingController();
  final identityPhoneController = TextEditingController();
  final relationshipInterestsController = TextEditingController();
  final relationshipLookingForController = TextEditingController();
  final relationshipPersonalityTagsController = TextEditingController();
  final relationshipContextNoteController = TextEditingController();
  final relationshipLastInteractionNoteController = TextEditingController();

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
        identity: _buildIdentity(),
        relationship: _buildRelationship(),
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

  ContactIdentity _buildIdentity() {
    return ContactIdentity(
      displayName: identityDisplayNameController.text.trim(),
      age: int.tryParse(identityAgeController.text.trim()),
      city: _normalizedText(identityCityController),
      company: _normalizedText(identityCompanyController),
      jobTitle: _normalizedText(identityJobTitleController),
      bio: _normalizedText(identityBioController),
      about: _normalizedText(identityAboutController),
      favoriteSong: _normalizedText(identityFavoriteSongController),
      email: _normalizedText(identityEmailController),
      phone: _normalizedText(identityPhoneController),
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
  }

  ContactRelationship _buildRelationship() {
    return ContactRelationship(
      contextNote: _normalizedText(relationshipContextNoteController),
      interests: _splitTags(relationshipInterestsController.text),
      lookingFor: _splitTags(relationshipLookingForController.text),
      personalityTags: _splitTags(relationshipPersonalityTagsController.text),
      lastInteractionNote: _normalizedText(
        relationshipLastInteractionNoteController,
      ),
    );
  }

  @override
  void dispose() {
    identityDisplayNameController.dispose();
    identityAgeController.dispose();
    identityCityController.dispose();
    identityCompanyController.dispose();
    identityJobTitleController.dispose();
    identityBioController.dispose();
    identityAboutController.dispose();
    identityFavoriteSongController.dispose();
    identityEmailController.dispose();
    identityPhoneController.dispose();
    relationshipInterestsController.dispose();
    relationshipLookingForController.dispose();
    relationshipPersonalityTagsController.dispose();
    relationshipContextNoteController.dispose();
    relationshipLastInteractionNoteController.dispose();
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
