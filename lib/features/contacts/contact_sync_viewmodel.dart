import 'package:flutter/foundation.dart';
import 'package:peoplesync/features/contacts/contact_import_service.dart';
import 'package:peoplesync/features/contacts/contact_service.dart';
import 'package:peoplesync/features/auth/auth_service.dart';

class ContactSyncViewModel extends ChangeNotifier {
  final ContactImportService importService;
  final ContactService contactService;
  final AuthService authService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _statusMessage;
  String? get statusMessage => _statusMessage;

  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;

  ContactSyncViewModel({
    required this.importService,
    required this.contactService,
    required this.authService,
  });

  Future<void> importContacts() async {
    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    _statusMessage = 'Solicitando permisos...';
    notifyListeners();

    try {
      final granted = await importService.requestPermission();
      if (!granted) {
        throw 'Debes conceder permisos para leer los contactos en los ajustes de tu telefono.';
      }

      _statusMessage = 'Leyendo contactos...';
      notifyListeners();

      final myUid = authService.currentUser?.uid;
      if (myUid == null) throw 'La sesion de usuario ha expirado.';

      final deviceContacts = await importService.getDeviceContacts();
      
      if (deviceContacts.isEmpty) {
        _statusMessage = 'La agenda del movil esta vacia.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _statusMessage = 'Importando ${deviceContacts.length} contactos...';
      notifyListeners();

      int count = 0;
      for (final deviceContact in deviceContacts) {
        final record = importService.mapToRecord(myUid, deviceContact);
        await contactService.createImportedContact(record);
        count++;
        // Emit events so the UI feels alive.
        if (count % 30 == 0 || count == deviceContacts.length) {
          _statusMessage = 'Importados $count de ${deviceContacts.length}...';
          notifyListeners();
        }
      }

      _isSuccess = true;
      _statusMessage = '¡Exito! Se importaron $count contactos a tu agenda.';
    } catch (e) {
      _errorMessage = e.toString();
      _statusMessage = 'Ocurrio un error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
