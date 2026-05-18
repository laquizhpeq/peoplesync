import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:peoplesync/core/services/app_error_mapper.dart';
import 'package:peoplesync/features/contacts/contact_import_service.dart';
import 'package:peoplesync/features/contacts/contact_service.dart';
import 'package:peoplesync/features/auth/auth_service.dart';
import 'package:peoplesync/features/contacts/models/contact_record.dart';

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
      _errorMessage = AppErrorMapper.toUserMessage(
        e,
        fallback:
            'No se pudieron importar los contactos. Vuelve a intentarlo.',
      );
      _statusMessage = 'Ocurrio un error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> importFromJson() async {
    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    _statusMessage = 'Selecciona un archivo JSON...';
    notifyListeners();

    try {
      final myUid = authService.currentUser?.uid;
      if (myUid == null || myUid.isEmpty) {
        throw 'La sesion de usuario ha expirado.';
      }

      final pickedFile = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['json'],
        withData: true,
      );

      if (pickedFile == null || pickedFile.files.isEmpty) {
        _statusMessage = 'Importacion cancelada.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final fileBytes = pickedFile.files.first.bytes;
      if (fileBytes == null || fileBytes.isEmpty) {
        throw 'No se pudo leer el archivo JSON seleccionado.';
      }

      _statusMessage = 'Leyendo JSON...';
      notifyListeners();

      final rawText = utf8.decode(fileBytes);
      final decoded = jsonDecode(rawText);
      final contactsPayload = _extractContactsPayload(decoded);

      if (contactsPayload.isEmpty) {
        _statusMessage = 'El JSON no contiene contactos para importar.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _statusMessage = 'Importando ${contactsPayload.length} contactos...';
      notifyListeners();

      var importedCount = 0;
      for (var i = 0; i < contactsPayload.length; i++) {
        final contactMap = contactsPayload[i];
        final contact = ContactRecord.fromJsonMap(contactMap);
        await contactService.createImportedContact(contact);
        importedCount++;

        if (importedCount % 30 == 0 || importedCount == contactsPayload.length) {
          _statusMessage = 'Importados $importedCount de ${contactsPayload.length}...';
          notifyListeners();
        }
      }

      _isSuccess = true;
      _statusMessage =
          'Exito: se importaron $importedCount contactos desde JSON.';
    } catch (e) {
      _errorMessage = AppErrorMapper.toUserMessage(
        e,
        fallback: 'No se pudo importar el archivo JSON. Revisa el formato.',
      );
      _statusMessage = 'Ocurrio un error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> _extractContactsPayload(dynamic decodedJson) {
    if (decodedJson is Map<String, dynamic>) {
      final dataNode = decodedJson['data'];
      if (dataNode is Map<String, dynamic>) {
        final contactsNode = dataNode['contacts'];
        if (contactsNode is List) {
          return contactsNode
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      }

      final contactsNode = decodedJson['contacts'];
      if (contactsNode is List) {
        return contactsNode
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }

    if (decodedJson is List) {
      return decodedJson
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return const [];
  }
}
