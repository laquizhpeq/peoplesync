import 'package:flutter_contacts/flutter_contacts.dart' as native_contacts;
import 'package:permission_handler/permission_handler.dart';
import 'package:peoplesync/features/contacts/models/contact_record.dart';

class ContactImportServiceException implements Exception {
  final String message;
  final Object? cause;

  const ContactImportServiceException(this.message, {this.cause});

  @override
  String toString() =>
      'ContactImportServiceException: $message${cause != null ? ' (causa: $cause)' : ''}';
}

class ContactImportService {
  /// Request permissions to read device contacts
  Future<bool> requestPermission() async {
    try {
      final status = await Permission.contacts.request();
      return status.isGranted;
    } catch (e) {
      throw ContactImportServiceException(
        'Fallo al solicitar permisos',
        cause: e,
      );
    }
  }

  /// Get contacts from the device natively
  Future<List<native_contacts.Contact>> getDeviceContacts() async {
    try {
      // In flutter_contacts 2.0, permissions can be checked via permission_handler
      // which we already do in requestPermission().
      // To fetch fields beyond ID and name, we explicitly define the properties.
      return await native_contacts.FlutterContacts.getAll(
        properties: {
          native_contacts.ContactProperty.name,
          native_contacts.ContactProperty.phone,
          native_contacts.ContactProperty.email,
          native_contacts.ContactProperty.organization,
        },
      );
    } catch (e) {
      throw ContactImportServiceException(
        'Error al leer contactos del movil',
        cause: e,
      );
    }
  }

  /// Convert a native contact into our ContactRecord model
  /// (Doesn't have an ownerUid yet until it's sent to ContactService)
  ContactRecord mapToRecord(
    String ownerUid,
    native_contacts.Contact deviceContact,
  ) {
    // Basic fields
    final displayName = deviceContact.displayName?.trim().isEmpty ?? true
        ? 'Sin Nombre'
        : deviceContact.displayName!;

    final phone = deviceContact.phones.isNotEmpty
        ? (deviceContact.phones.first.normalizedNumber?.isNotEmpty == true
              ? deviceContact.phones.first.normalizedNumber
              : deviceContact.phones.first.number)
        : null;

    final email = deviceContact.emails.isNotEmpty
        ? deviceContact.emails.first.address
        : null;

    final jobTitle = deviceContact.organizations.isNotEmpty
        ? deviceContact.organizations.first.jobTitle
        : null;

    final company = deviceContact.organizations.isNotEmpty
        ? deviceContact.organizations.first.name
        : null;

    final baseId =
        deviceContact.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final generatedDeviceContactId = 'device_$baseId';

    return ContactRecord(
      id: generatedDeviceContactId, // temporary/default ID based on the phone's agenda
      ownerUid: ownerUid,
      source: ContactSource.deviceImport,
      deviceContactId: baseId,
      identity: ContactIdentity(
        displayName: displayName,
        phone: phone,
        email: email,
        jobTitle: jobTitle,
        company: company,
      ),
      relationship: const ContactRelationship(
        contextNote: 'Importado del telefono',
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
