import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:peoplesync/features/contacts/models/contact_record.dart';

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
    return _contactsCollection(uid)
        .orderBy('updated_at', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ContactRecord.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<List<ContactRecord>> fetchContacts() async {
    final uid = _currentUid;
    final snapshot = await _contactsCollection(uid)
        .orderBy('updated_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ContactRecord.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> createManualContact({
    required String displayName,
    String? email,
    String? phone,
    String? city,
    String? company,
    String? jobTitle,
    String? bio,
    String? favoriteSong,
    List<String> interests = const [],
    List<String> tags = const [],
    String? contextNote,
  }) async {
    final uid = _currentUid;
    final doc = _contactsCollection(uid).doc();

    final contact = ContactRecord(
      id: doc.id,
      ownerUid: uid,
      source: ContactSource.manual,
      displayName: displayName,
      email: email,
      phone: phone,
      city: city,
      company: company,
      jobTitle: jobTitle,
      bio: bio,
      favoriteSong: favoriteSong,
      interests: interests,
      tags: tags,
      contextNote: contextNote,
    );

    await doc.set(contact.toMap());
  }

  Future<void> createLinkedContact({
    required String linkedUserUid,
    required String displayName,
    String? photoUrl,
    String? email,
    String? favoriteSong,
    List<String> interests = const [],
    List<String> tags = const [],
    String? contextNote,
  }) async {
    final uid = _currentUid;
    final doc = _contactsCollection(uid).doc(linkedUserUid);

    final contact = ContactRecord(
      id: doc.id,
      ownerUid: uid,
      source: ContactSource.linkedUser,
      displayName: displayName,
      linkedUserUid: linkedUserUid,
      photoUrl: photoUrl,
      email: email,
      favoriteSong: favoriteSong,
      interests: interests,
      tags: tags,
      contextNote: contextNote,
    );

    await doc.set(contact.toMap(), SetOptions(merge: true));
  }

  Future<void> updateContact({
    required String contactId,
    String? displayName,
    String? email,
    String? phone,
    String? city,
    String? company,
    String? jobTitle,
    String? bio,
    String? favoriteSong,
    List<String>? interests,
    List<String>? tags,
    String? contextNote,
    DateTime? lastInteractionAt,
  }) async {
    final uid = _currentUid;
    final updates = <String, dynamic>{
      'updated_at': FieldValue.serverTimestamp(),
    };

    if (displayName != null) updates['display_name'] = displayName;
    if (email != null) updates['email'] = email;
    if (phone != null) updates['phone'] = phone;
    if (city != null) updates['city'] = city;
    if (company != null) updates['company'] = company;
    if (jobTitle != null) updates['job_title'] = jobTitle;
    if (bio != null) updates['bio'] = bio;
    if (favoriteSong != null) updates['favorite_song'] = favoriteSong;
    if (interests != null) updates['interests'] = interests;
    if (tags != null) updates['tags'] = tags;
    if (contextNote != null) updates['context_note'] = contextNote;
    if (lastInteractionAt != null) {
      updates['last_interaction_at'] = Timestamp.fromDate(lastInteractionAt);
    }

    await _contactsCollection(uid).doc(contactId).update(updates);
  }

  Future<void> deleteContact(String contactId) async {
    final uid = _currentUid;
    await _contactsCollection(uid).doc(contactId).delete();
  }
}
