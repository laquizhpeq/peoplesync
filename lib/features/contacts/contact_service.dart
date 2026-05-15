import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';
import 'package:peoplesync/core/config/env_config.dart';
import 'package:peoplesync/features/contacts/models/contact_record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Excepción tipada para operaciones del [ContactService].
class ContactServiceException implements Exception {
  final String message;
  final Object? cause;

  const ContactServiceException(this.message, {this.cause});

  @override
  String toString() =>
      'ContactServiceException: $message${cause != null ? ' (causa: $cause)' : ''}';
}

class ContactService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUid {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw Exception('No hay un usuario autenticado');
    }
    return uid;
  }

  CollectionReference<Map<String, dynamic>> _contactsCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('contacts');
  }

  Stream<List<ContactRecord>> watchContacts() {
    final uid = _currentUid;
    return _contactsCollection(uid).snapshots().map(
      (snapshot) =>
          snapshot.docs
              .map((doc) => ContactRecord.fromMap(doc.data(), doc.id))
              .toList()
            ..sort(_sortContacts),
    );
  }

  Future<List<ContactRecord>> fetchContacts() async {
    final uid = _currentUid;
    final snapshot = await _contactsCollection(uid).get();

    return snapshot.docs
        .map((doc) => ContactRecord.fromMap(doc.data(), doc.id))
        .toList()
      ..sort(_sortContacts);
  }

  String generateContactId() {
    final uid = _currentUid;
    return _contactsCollection(uid).doc().id;
  }

  Future<String> uploadContactPhoto({
    required String contactId,
    required Uint8List bytes,
  }) async {
    final uid = _currentUid;
    final bucket = EnvConfig.supabaseContactPhotosBucket;
    final folder = EnvConfig.supabaseContactPhotosFolder;

    if (EnvConfig.supabaseUrl.isEmpty || EnvConfig.supabaseAnonKey.isEmpty) {
      throw const ContactServiceException(
        'Supabase no esta configurado en .env.',
      );
    }

    if (bucket.isEmpty) {
      throw const ContactServiceException(
        'Falta SUPABASE_CONTACT_PHOTOS_BUCKET en .env.',
      );
    }

    final storage = Supabase.instance.client.storage.from(bucket);
    final filePath =
        '$folder/$uid/$contactId/${DateTime.now().millisecondsSinceEpoch}.jpg';

    await storage.uploadBinary(
      filePath,
      bytes,
      fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
    );

    return storage.getPublicUrl(filePath);
  }

  Future<String> createManualContact({
    required ContactIdentity identity,
    ContactRelationship relationship = const ContactRelationship(),
    String? contactId,
  }) async {
    final uid = _currentUid;
    final doc = contactId == null
        ? _contactsCollection(uid).doc()
        : _contactsCollection(uid).doc(contactId);

    final contact = ContactRecord(
      id: doc.id,
      ownerUid: uid,
      source: ContactSource.manual,
      identity: identity,
      relationship: relationship,
    );

    await doc.set(contact.toMap());
    return doc.id;
  }

  Future<void> createImportedContact(ContactRecord contact) async {
    final uid = _currentUid;
    // We use the ID returned by mapToRecord to prevent duplicates
    // when syncing multiple times.
    final docId = contact.id.isEmpty
        ? _contactsCollection(uid).doc().id
        : contact.id;
    final doc = _contactsCollection(uid).doc(docId);

    // Ensure the record is linked to this uid just in case
    final finalContact = ContactRecord(
      id: doc.id,
      ownerUid: uid,
      source: contact.source,
      deviceContactId: contact.deviceContactId,
      identity: contact.identity,
      relationship: contact.relationship,
    );

    await doc.set(finalContact.toMap(), SetOptions(merge: true));
  }

  Future<void> createLinkedContact({
    required String linkedUserUid,
    required String displayName,
    String? photoUrl,
    String? favoriteSong,
    String? email,
    String? bio,
    List<String> interests = const [],
    List<String> lookingFor = const [],
    List<String> personalityTags = const [],
    String? relationshipContext,
    List<ContactSocialProfile> socialProfiles = const [],
    String? importedFromQrId,
  }) async {
    final uid = _currentUid;
    final doc = _contactsCollection(uid).doc(linkedUserUid);

    final contact = ContactRecord(
      id: doc.id,
      ownerUid: uid,
      source: ContactSource.linkedUser,
      linkedUserUid: linkedUserUid,
      importedFromQrId: importedFromQrId,
      identity: ContactIdentity(
        displayName: displayName,
        photoUrl: photoUrl,
        favoriteSong: favoriteSong,
        email: email,
        bio: bio,
        socialProfiles: socialProfiles,
      ),
      relationship: ContactRelationship(
        contextNote: relationshipContext,
        interests: interests,
        lookingFor: lookingFor,
        personalityTags: personalityTags,
      ),
    );

    await doc.set(contact.toMap(), SetOptions(merge: true));
  }

  Future<void> updateContact({
    required String contactId,
    String? displayName,
    String? photoUrl,
    int? age,
    DateTime? birthday,
    String? city,
    String? company,
    String? jobTitle,
    String? bio,
    String? about,
    String? favoriteSong,
    String? email,
    String? phone,
    List<String>? interests,
    List<String>? lookingFor,
    List<String>? personalityTags,
    String? relationshipContext,
    String? lastInteractionNote,
    List<ContactSocialProfile>? socialProfiles,
    DateTime? lastInteractionAt,
  }) async {
    final uid = _currentUid;
    final updates = <String, dynamic>{
      'updated_at': FieldValue.serverTimestamp(),
    };

    if (displayName != null) {
      updates['identity.display_name'] = displayName;
    }
    if (photoUrl != null) updates['identity.photo_url'] = photoUrl;
    if (age != null) updates['identity.age'] = age;
    if (birthday != null) {
      updates['identity.birthday'] = Timestamp.fromDate(birthday);
    }
    if (city != null) updates['identity.city'] = city;
    if (company != null) updates['identity.company'] = company;
    if (jobTitle != null) updates['identity.job_title'] = jobTitle;
    if (bio != null) updates['identity.bio'] = bio;
    if (about != null) updates['identity.about'] = about;
    if (favoriteSong != null) {
      updates['identity.favorite_song'] = favoriteSong;
    }
    if (email != null) updates['identity.email'] = email;
    if (phone != null) updates['identity.phone'] = phone;
    if (socialProfiles != null) {
      updates['identity.social_profiles'] = socialProfiles
          .map((profile) => profile.toMap())
          .toList();
    }

    if (interests != null) updates['relationship.interests'] = interests;
    if (lookingFor != null) {
      updates['relationship.looking_for'] = lookingFor;
    }
    if (personalityTags != null) {
      updates['relationship.personality_tags'] = personalityTags;
    }
    if (relationshipContext != null) {
      updates['relationship.context_note'] = relationshipContext;
    }
    if (lastInteractionNote != null) {
      updates['relationship.last_interaction_note'] = lastInteractionNote;
    }
    if (lastInteractionAt != null) {
      updates['relationship.last_interaction_at'] = Timestamp.fromDate(
        lastInteractionAt,
      );
    }

    await _contactsCollection(uid).doc(contactId).update(updates);
  }

  Future<void> deleteContact(String contactId) async {
    final uid = _currentUid;
    await _contactsCollection(uid).doc(contactId).delete();
  }

  // ---------------------------------------------------------------------------
  // Networking — métodos de la funcionalidad de contactos por QR
  // ---------------------------------------------------------------------------

  /// Guarda un contacto escaneado via QR en la subcolección del usuario.
  ///
  /// Obtiene el perfil público de [contactoUid] desde la colección maestra
  /// `users`, construye un [ContactRecord] con [ContactSource.qrImport] y lo
  /// persiste en `/users/[miUid]/contacts/[contactoUid]`.
  Future<void> saveScannedContact({
    required String miUid,
    required String contactoUid,
    String? notaContexto,
  }) async {
    try {
      // a. Obtener perfil público desde la colección maestra.
      final userDoc = await _firestore
          .collection('users')
          .doc(contactoUid)
          .get();

      if (!userDoc.exists || userDoc.data() == null) {
        throw ContactServiceException(
          'El perfil del usuario $contactoUid no existe en la colección maestra.',
        );
      }

      // b. Mapear datos públicos a ContactIdentity.
      final identity = ContactIdentity.fromMap(
        Map<String, dynamic>.from(userDoc.data()!),
      );

      // c. Construir el ContactRecord completo.
      final nuevoContacto = ContactRecord(
        id: contactoUid,
        ownerUid: miUid,
        source: ContactSource.qrImport,
        linkedUserUid: contactoUid,
        identity: identity,
        relationship: ContactRelationship(contextNote: notaContexto),
      );

      // d. Persistir en la subcolección del usuario.
      await _contactsCollection(
        miUid,
      ).doc(contactoUid).set(nuevoContacto.toMap());
    } on ContactServiceException {
      rethrow;
    } catch (e) {
      throw ContactServiceException(
        'Error al guardar el contacto escaneado.',
        cause: e,
      );
    }
  }

  /// Retorna un [Stream] reactivo de todos los contactos de [miUid],
  /// ordenados por `updated_at` descendente.
  ///
  /// Usa la query nativa de Firestore para el `orderBy` en lugar de
  /// ordenar en cliente, reduciendo el procesamiento innecesario.
  Stream<List<ContactRecord>> streamMyContacts(String miUid) {
    try {
      return _contactsCollection(miUid)
          .orderBy('updated_at', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => ContactRecord.fromMap(doc.data(), doc.id))
                .toList(),
          );
    } catch (e) {
      throw ContactServiceException(
        'Error al inicializar el stream de contactos para $miUid.',
        cause: e,
      );
    }
  }

  /// Sincroniza el campo `identity` de un contacto guardado con los datos
  /// más recientes del perfil público en la colección maestra `users`.
  ///
  /// Solo toca el sub-mapa `identity` — las `private_notes` y el resto del
  /// `relationship` quedan intactos.
  Future<void> syncContactIdentity({
    required String miUid,
    required String contactoUid,
  }) async {
    try {
      // Obtener el perfil público actualizado.
      final userDoc = await _firestore
          .collection('users')
          .doc(contactoUid)
          .get();

      if (!userDoc.exists || userDoc.data() == null) {
        throw ContactServiceException(
          'No se encontró el perfil de $contactoUid para sincronizar.',
        );
      }

      final identity = ContactIdentity.fromMap(
        Map<String, dynamic>.from(userDoc.data()!),
      );

      // Actualizar solo el campo `identity` y el timestamp de actualización.
      await _contactsCollection(miUid).doc(contactoUid).update({
        'identity': identity.toMap(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    } on ContactServiceException {
      rethrow;
    } catch (e) {
      throw ContactServiceException(
        'Error al sincronizar la identidad del contacto $contactoUid.',
        cause: e,
      );
    }
  }

  /// Actualiza solo el campo `relationship.private_notes` de un contacto.
  ///
  /// Usa dot-notation de Firestore para un update quirúrgico sin tocar
  /// ningún otro campo del documento.
  Future<void> updatePrivateNotes({
    required String contactId,
    required String? privateNotes,
  }) async {
    try {
      final uid = _currentUid;
      await _contactsCollection(uid).doc(contactId).update({
        'relationship.private_notes': privateNotes,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ContactServiceException(
        'Error al actualizar las notas privadas del contacto $contactId.',
        cause: e,
      );
    }
  }

  Future<void> updateFavoriteStatus({
    required String contactId,
    required bool isFavorite,
  }) async {
    try {
      final uid = _currentUid;
      await _contactsCollection(uid).doc(contactId).update({
        'relationship.is_favorite': isFavorite,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ContactServiceException(
        'Error al actualizar favorito del contacto $contactId.',
        cause: e,
      );
    }
  }

  Future<void> updateStrengthenRelationshipStatus({
    required String contactId,
    required bool wantsToStrengthenRelationship,
  }) async {
    try {
      final uid = _currentUid;
      await _contactsCollection(uid).doc(contactId).update({
        'relationship.wants_to_strengthen_relationship':
            wantsToStrengthenRelationship,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ContactServiceException(
        'Error al actualizar relacion a cuidar del contacto $contactId.',
        cause: e,
      );
    }
  }
}

int _sortContacts(ContactRecord a, ContactRecord b) {
  final aDate =
      a.updatedAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
  final bDate =
      b.updatedAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
  return bDate.compareTo(aDate);
}
