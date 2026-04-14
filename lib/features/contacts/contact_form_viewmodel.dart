import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:peoplesync/features/contacts/contact_service.dart';
import 'package:peoplesync/features/contacts/models/contact_record.dart';

class ContactFormViewModel extends ChangeNotifier {
  final ContactService contactService;
  final ContactRecord? initialContact;

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
  final ImagePicker _imagePicker = ImagePicker();

  final List<ContactSocialProfileDraft> socialProfiles = [
    ContactSocialProfileDraft(),
  ];

  bool _isSaving = false;
  Uint8List? _selectedPhotoBytes;
  String? _photoUrl;
  String? _photoPickerError;

  bool get isSaving => _isSaving;
  bool get isEditMode => initialContact != null;
  String get submitLabel => isEditMode ? 'Guardar cambios' : 'Guardar contacto';
  Uint8List? get selectedPhotoBytes => _selectedPhotoBytes;
  String? get photoUrl => _photoUrl;
  String? get photoPickerError => _photoPickerError;
  bool get hasPhoto =>
      _selectedPhotoBytes != null ||
      (_photoUrl != null && _photoUrl!.isNotEmpty);

  ContactFormViewModel({required this.contactService, this.initialContact}) {
    _seedFromInitialContact();
  }

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

  Future<void> pickPhoto() async {
    try {
      _photoPickerError = null;

      if (_usesDesktopPicker) {
        final picked = await _pickWithFilePicker();
        if (picked) notifyListeners();
        return;
      }

      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 82,
        maxWidth: 1600,
      );
      if (file == null) return;

      _selectedPhotoBytes = await file.readAsBytes();
      notifyListeners();
    } on MissingPluginException {
      if (_usesDesktopPicker) {
        try {
          final picked = await _pickWithFilePicker();
          if (picked) {
            notifyListeners();
            return;
          }
        } catch (_) {}
      }

      _photoPickerError =
          'El selector de imagen no esta cargado. Cierra la app por completo y vuelvela a abrir.';
      notifyListeners();
    } catch (e) {
      if ('$e'.contains('LateInitializationError')) {
        _photoPickerError =
            'El selector de archivos no esta disponible en esta ejecucion. Reinicia la app completamente.';
        notifyListeners();
        return;
      }

      _photoPickerError = 'No se pudo abrir la galeria: $e';
      notifyListeners();
    }
  }

  void removePhoto() {
    _selectedPhotoBytes = null;
    _photoUrl = '';
    _photoPickerError = null;
    notifyListeners();
  }

  bool get _usesDesktopPicker {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  Future<bool> _pickWithFilePicker() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return false;

    final bytes = result.files.single.bytes;
    if (bytes == null) {
      _photoPickerError = 'No se pudo leer la imagen seleccionada';
      return false;
    }

    _selectedPhotoBytes = bytes;
    _photoPickerError = null;
    return true;
  }

  Future<String?> saveContact() async {
    if (!formKey.currentState!.validate()) return 'invalid';

    _isSaving = true;
    notifyListeners();

    try {
      final targetContactId = isEditMode
          ? initialContact!.id
          : contactService.generateContactId();
      final uploadedPhotoUrl = await _resolvePhotoUrlSafe(targetContactId);

      if (isEditMode) {
        await contactService.updateContact(
          contactId: targetContactId,
          displayName: identityDisplayNameController.text.trim(),
          photoUrl: uploadedPhotoUrl,
          age: int.tryParse(identityAgeController.text.trim()),
          city: _normalizedUpdateText(identityCityController),
          company: _normalizedUpdateText(identityCompanyController),
          jobTitle: _normalizedUpdateText(identityJobTitleController),
          bio: _normalizedUpdateText(identityBioController),
          about: _normalizedUpdateText(identityAboutController),
          favoriteSong: _normalizedUpdateText(identityFavoriteSongController),
          email: _normalizedUpdateText(identityEmailController),
          phone: _normalizedUpdateText(identityPhoneController),
          interests: _splitTags(relationshipInterestsController.text),
          lookingFor: _splitTags(relationshipLookingForController.text),
          personalityTags: _splitTags(
            relationshipPersonalityTagsController.text,
          ),
          relationshipContext: _normalizedUpdateText(
            relationshipContextNoteController,
          ),
          lastInteractionNote: _normalizedUpdateText(
            relationshipLastInteractionNoteController,
          ),
          socialProfiles: _buildSocialProfiles(),
        );
      } else {
        await contactService.createManualContact(
          contactId: targetContactId,
          identity: _buildIdentity(photoUrl: uploadedPhotoUrl),
          relationship: _buildRelationship(),
        );
      }

      _photoUrl = uploadedPhotoUrl;
      _selectedPhotoBytes = null;

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

  String _normalizedUpdateText(TextEditingController controller) {
    return controller.text.trim();
  }

  Future<String?> _resolvePhotoUrlSafe(String contactId) async {
    if (_selectedPhotoBytes != null) {
      try {
        return await contactService.uploadContactPhoto(
          contactId: contactId,
          bytes: _selectedPhotoBytes!,
        );
      } catch (e) {
        _photoPickerError =
            'La foto no se pudo subir. El contacto se guardara sin cambiar la foto.';
        return _photoUrl;
      }
    }

    return _photoUrl;
  }

  ContactIdentity _buildIdentity({String? photoUrl}) {
    return ContactIdentity(
      displayName: identityDisplayNameController.text.trim(),
      photoUrl: photoUrl,
      age: int.tryParse(identityAgeController.text.trim()),
      city: _normalizedText(identityCityController),
      company: _normalizedText(identityCompanyController),
      jobTitle: _normalizedText(identityJobTitleController),
      bio: _normalizedText(identityBioController),
      about: _normalizedText(identityAboutController),
      favoriteSong: _normalizedText(identityFavoriteSongController),
      email: _normalizedText(identityEmailController),
      phone: _normalizedText(identityPhoneController),
      socialProfiles: _buildSocialProfiles(),
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

  List<ContactSocialProfile> _buildSocialProfiles() {
    return socialProfiles
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
        .toList();
  }

  void _seedFromInitialContact() {
    final contact = initialContact;
    if (contact == null) return;

    _photoUrl = contact.identity.photoUrl;
    identityDisplayNameController.text = contact.displayName;
    identityAgeController.text = contact.identity.age?.toString() ?? '';
    identityCityController.text = contact.identity.city ?? '';
    identityCompanyController.text = contact.identity.company ?? '';
    identityJobTitleController.text = contact.identity.jobTitle ?? '';
    identityBioController.text = contact.identity.bio ?? '';
    identityAboutController.text = contact.identity.about ?? '';
    identityFavoriteSongController.text = contact.identity.favoriteSong ?? '';
    identityEmailController.text = contact.identity.email ?? '';
    identityPhoneController.text = contact.identity.phone ?? '';
    relationshipInterestsController.text = contact.relationship.interests.join(
      ', ',
    );
    relationshipLookingForController.text = contact.relationship.lookingFor
        .join(', ');
    relationshipPersonalityTagsController.text = contact
        .relationship
        .personalityTags
        .join(', ');
    relationshipContextNoteController.text =
        contact.relationship.contextNote ?? '';
    relationshipLastInteractionNoteController.text =
        contact.relationship.lastInteractionNote ?? '';

    for (final social in socialProfiles) {
      social.dispose();
    }
    socialProfiles
      ..clear()
      ..addAll(
        contact.identity.socialProfiles.isEmpty
            ? [ContactSocialProfileDraft()]
            : contact.identity.socialProfiles
                  .map(
                    (profile) =>
                        ContactSocialProfileDraft(platform: profile.platform)
                          ..valueController.text = profile.value
                          ..labelController.text = profile.label ?? ''
                          ..urlController.text = profile.url ?? '',
                  )
                  .toList(),
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
