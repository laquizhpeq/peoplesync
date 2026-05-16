import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:peoplesync/core/services/app_logger.dart';
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
      AppLogger.warning(
        'Se intento inicializar conexiones sin usuario autenticado',
        scope: 'connections',
      );
      clear();
      return;
    }

    if (_initializedUid == currentUid && _subscription != null) {
      AppLogger.debug(
        'Conexiones ya inicializadas para el usuario actual',
        scope: 'connections',
      );
      return;
    }

    AppLogger.info(
      'Inicializando stream de conexiones para el usuario actual',
      scope: 'connections',
    );
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
            if (contacts.isEmpty) {
              AppLogger.info(
                'El usuario no tiene contactos guardados',
                scope: 'connections',
              );
            } else {
              AppLogger.debug(
                'Conexiones cargadas: ${contacts.length}',
                scope: 'connections',
              );
            }
            notifyListeners();
          },
          onError: (error) {
            _errorMessage = '$error';
            _isLoading = false;
            AppLogger.error(
              'Fallo el stream de conexiones',
              scope: 'connections',
              error: error,
            );
            notifyListeners();
          },
        );
  }

  void clear() {
    AppLogger.debug('Limpiando estado de conexiones', scope: 'connections');
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
      AppLogger.error(
        'No se pudo sincronizar la identidad del contacto',
        scope: 'connections',
        error: e,
      );
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
      AppLogger.error(
        'No se pudieron guardar notas privadas',
        scope: 'connections',
        error: e,
      );
      _errorMessage = 'Error al actualizar notas: $e';
      notifyListeners();
    }
  }

  Future<void> updateRelationshipType(
    String contactId,
    String? relationshipType,
  ) async {
    try {
      await contactService.updateContact(
        contactId: contactId,
        relationshipType: relationshipType ?? '',
      );
    } catch (e) {
      AppLogger.error(
        'No se pudo actualizar el tipo de relacion',
        scope: 'connections',
        error: e,
      );
      _errorMessage = 'Error al actualizar el tipo de relacion: $e';
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
      AppLogger.error(
        'No se pudo actualizar favorito',
        scope: 'connections',
        error: e,
      );
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
      AppLogger.error(
        'No se pudo actualizar la relacion a cuidar',
        scope: 'connections',
        error: e,
      );
      _errorMessage = 'Error al actualizar relacion a cuidar: $e';
      notifyListeners();
    }
  }

  Future<String?> deleteContact(String contactId) async {
    try {
      await contactService.deleteContact(contactId);
      return null;
    } catch (e) {
      AppLogger.error(
        'No se pudo eliminar el contacto',
        scope: 'connections',
        error: e,
      );
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
