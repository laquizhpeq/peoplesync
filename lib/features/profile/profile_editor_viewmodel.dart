import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:peoplesync/core/services/app_error_mapper.dart';
import 'package:peoplesync/features/contacts/models/contact_record.dart';
import 'package:peoplesync/features/profile/models/spotify_track.dart';
import 'package:peoplesync/features/profile/models/user_profile.dart';
import 'package:peoplesync/features/profile/profile_service.dart';
import 'package:peoplesync/features/profile/spotify_service.dart';

class ProfileEditorViewModel extends ChangeNotifier {
  final ProfileService profileService;
  final SpotifyService spotifyService;
  final bool markOnboardingCompleteOnSave;

  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final cityController = TextEditingController();
  final bioController = TextEditingController();
  final favoriteSongController = TextEditingController();
  final affinitiesController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  final List<ProfileSocialProfileDraft> socialProfiles = [
    ProfileSocialProfileDraft(),
  ];

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isPickingPhoto = false;
  String? _errorMessage;
  UserProfile? _profile;

  Uint8List? _selectedPhotoBytes;
  String? _photoUrl;
  String? _photoPickerError;
  bool _isSearchingSpotify = false;
  List<SpotifyTrack> _spotifyResults = const [];
  SpotifyTrack? _selectedSpotifyTrack;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isPickingPhoto => _isPickingPhoto;
  String? get errorMessage => _errorMessage;
  UserProfile? get profile => _profile;
  Uint8List? get selectedPhotoBytes => _selectedPhotoBytes;
  String? get photoUrl => _photoUrl;
  String? get photoPickerError => _photoPickerError;
  bool get isSearchingSpotify => _isSearchingSpotify;
  List<SpotifyTrack> get spotifyResults => _spotifyResults;
  SpotifyTrack? get selectedSpotifyTrack => _selectedSpotifyTrack;
  bool get hasPhoto =>
      _selectedPhotoBytes != null ||
      (_photoUrl != null && _photoUrl!.isNotEmpty);

  ProfileEditorViewModel({
    required this.profileService,
    required this.spotifyService,
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
      _errorMessage = AppErrorMapper.toUserMessage(
        e,
        fallback: 'No se pudo cargar tu perfil. Reintenta en unos segundos.',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pickPhoto() async {
    if (_isPickingPhoto) {
      _photoPickerError = 'La galeria ya se esta abriendo. Espera un momento.';
      notifyListeners();
      return;
    }

    _isPickingPhoto = true;
    _photoPickerError = null;
    notifyListeners();

    try {
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
    } on PlatformException catch (e) {
      if (e.code == 'already_active') {
        _photoPickerError =
            'La galeria ya se esta abriendo. Espera un momento.';
        notifyListeners();
        return;
      }

      _photoPickerError = AppErrorMapper.toUserMessage(
        e,
        fallback: 'No se pudo abrir la galeria. Vuelve a intentarlo.',
      );
      notifyListeners();
    } catch (e) {
      if ('$e'.contains('LateInitializationError')) {
        _photoPickerError =
            'El selector de archivos no esta disponible en esta ejecucion. Reinicia la app completamente.';
        notifyListeners();
        return;
      }

      _photoPickerError = AppErrorMapper.toUserMessage(
        e,
        fallback: 'No se pudo abrir la galeria. Vuelve a intentarlo.',
      );
      notifyListeners();
    } finally {
      _isPickingPhoto = false;
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
      final uploadedPhotoUrl = await _resolvePhotoUrl();

      await profileService.saveProfile(
        fullName: fullNameController.text.trim(),
        photoUrl: uploadedPhotoUrl,
        city: _normalizedText(cityController),
        bio: _normalizedText(bioController),
        favoriteSong: _normalizedText(favoriteSongController),
        favoriteSongTrackId: _selectedSpotifyTrack?.id,
        favoriteSongArtist: _selectedSpotifyTrack?.artist,
        favoriteSongCoverUrl: _selectedSpotifyTrack?.albumImageUrl,
        favoriteSongExternalUrl: _selectedSpotifyTrack?.externalUrl,
        affinities: _normalizedTags(affinitiesController.text),
        socialProfiles: _buildSocialProfiles(),
        onboardingCompleted: markOnboardingCompleteOnSave ? true : null,
      );

      _photoUrl = uploadedPhotoUrl;
      _selectedPhotoBytes = null;
      _profile = await profileService.getProfile(forceRefresh: true);
      return true;
    } catch (e) {
      _errorMessage = AppErrorMapper.toUserMessage(
        e,
        fallback: 'No se pudo guardar tu perfil. Vuelve a intentarlo.',
      );
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<String?> _resolvePhotoUrl() async {
    if (_selectedPhotoBytes != null) {
      return profileService.uploadProfilePhoto(bytes: _selectedPhotoBytes!);
    }
    return _photoUrl;
  }

  Future<void> searchSpotifyTrack() async {
    final query = favoriteSongController.text.trim();
    if (query.isEmpty) {
      _spotifyResults = const [];
      _errorMessage = 'Escribe una cancion antes de buscar en Spotify.';
      notifyListeners();
      return;
    }

    _isSearchingSpotify = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _spotifyResults = await spotifyService.searchTracks(query);
      if (_spotifyResults.isEmpty) {
        _errorMessage = 'Spotify no devolvio resultados para esa busqueda.';
      }
    } catch (_) {
      _errorMessage = 'Esta caracteristica aun no esta disponible.';
    } finally {
      _isSearchingSpotify = false;
      notifyListeners();
    }
  }

  void selectSpotifyTrack(SpotifyTrack track) {
    _selectedSpotifyTrack = track;
    favoriteSongController.text = track.name;
    _spotifyResults = const [];
    notifyListeners();
  }

  void clearSpotifyTrack() {
    _selectedSpotifyTrack = null;
    notifyListeners();
  }

  void _hydrateControllers(UserProfile? profile) {
    fullNameController.text = profile?.fullName ?? '';
    _photoUrl = profile?.photoUrl;
    cityController.text = profile?.city ?? '';
    bioController.text = profile?.bio ?? '';
    favoriteSongController.text = profile?.favoriteSong ?? '';
    affinitiesController.text = (profile?.affinities ?? const <String>[])
        .join(', ');
    if (profile?.favoriteSongTrackId?.trim().isNotEmpty == true) {
      _selectedSpotifyTrack = SpotifyTrack(
        id: profile!.favoriteSongTrackId!,
        name: profile.favoriteSong ?? '',
        artist: profile.favoriteSongArtist ?? 'Artista desconocido',
        albumImageUrl: profile.favoriteSongCoverUrl,
        externalUrl: profile.favoriteSongExternalUrl ?? '',
      );
    } else {
      _selectedSpotifyTrack = null;
    }

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
      profiles.map((profile) => ProfileSocialProfileDraft.fromProfile(profile)),
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

  List<String> _normalizedTags(String rawValue) {
    return rawValue
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    cityController.dispose();
    bioController.dispose();
    favoriteSongController.dispose();
    affinitiesController.dispose();
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
