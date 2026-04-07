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

  List<ContactRecord> get contacts => _contacts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ConnectionsViewModel({
    required this.contactService,
    required this.authService,
  }) {
    _subscribe();
  }

  void _subscribe() {
    final uid = authService.currentUser?.uid;
    if (uid == null) {
      _errorMessage = 'No hay sesión de usuario activa.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Usamos streamMyContacts para que Firestore se encargue del ordenamiento por 'updated_at'.
    _subscription = contactService
        .streamMyContacts(uid)
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

  /// Sincroniza la identidad del contacto con su perfil público actualizado.
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

  /// Actualiza las notas privadas de una conexión.
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

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
