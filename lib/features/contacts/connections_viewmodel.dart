import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:peoplesync/features/auth/auth_service.dart';
import 'package:peoplesync/features/contacts/contact_service.dart';
import 'package:peoplesync/features/contacts/models/contact_record.dart';

class ConnectionsViewModel extends ChangeNotifier {
  final ContactService contactService;
  final AuthService authService;

  List<ContactRecord> _contacts = [];
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<List<ContactRecord>>? _subscription;
  String? _initializedUid;

  List<ContactRecord> get contacts => _contacts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ConnectionsViewModel({
    required this.contactService,
    required this.authService,
  });

  void initialize() {
    final currentUid = authService.currentUser?.uid;
    if (currentUid == null || currentUid.isEmpty) {
      clear();
      return;
    }

    if (_initializedUid == currentUid && _subscription != null) {
      return;
    }

    _subscription?.cancel();
    _initializedUid = currentUid;
    _isLoading = _contacts.isEmpty;
    _errorMessage = null;
    notifyListeners();

    _subscription = contactService
        .streamMyContacts(currentUid)
        .listen(
          (contacts) {
            _contacts = contacts;
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (error) {
            _errorMessage = '$error';
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  void clear() {
    _subscription?.cancel();
    _subscription = null;
    _initializedUid = null;
    _contacts = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> syncContact(String contactoUid) async {
    final miUid = authService.currentUser?.uid;
    if (miUid == null) return;

    try {
      await contactService.syncContactIdentity(
        miUid: miUid,
        contactoUid: contactoUid,
      );
    } catch (e) {
      _errorMessage = 'Error al sincronizar: $e';
      notifyListeners();
    }
  }

  Future<void> updateNotes(String contactId, String? notes) async {
    try {
      await contactService.updatePrivateNotes(
        contactId: contactId,
        privateNotes: notes,
      );
    } catch (e) {
      _errorMessage = 'Error al actualizar notas: $e';
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String contactId, bool isFavorite) async {
    try {
      await contactService.updateFavoriteStatus(
        contactId: contactId,
        isFavorite: isFavorite,
      );
    } catch (e) {
      _errorMessage = 'Error al actualizar favorito: $e';
      notifyListeners();
    }
  }

  Future<void> toggleStrengthenRelationship(
    String contactId,
    bool wantsToStrengthenRelationship,
  ) async {
    try {
      await contactService.updateStrengthenRelationshipStatus(
        contactId: contactId,
        wantsToStrengthenRelationship: wantsToStrengthenRelationship,
      );
    } catch (e) {
      _errorMessage = 'Error al actualizar relacion a cuidar: $e';
      notifyListeners();
    }
  }

  Future<String?> deleteContact(String contactId) async {
    try {
      await contactService.deleteContact(contactId);
      return null;
    } catch (e) {
      _errorMessage = 'Error al eliminar contacto: $e';
      notifyListeners();
      return _errorMessage;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
