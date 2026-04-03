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

  Future<void> createManualContact({
    required ContactIdentity identity,
    ContactRelationship relationship = const ContactRelationship(),
  }) async {
    final uid = _currentUid;
    final doc = _contactsCollection(uid).doc();

    final contact = ContactRecord(
      id: doc.id,
      ownerUid: uid,
      source: ContactSource.manual,
      identity: identity,
      relationship: relationship,
    );

    await doc.set(contact.toMap());
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
      updates['relationship.last_interaction_at'] =
          Timestamp.fromDate(lastInteractionAt);
    }

    await _contactsCollection(uid).doc(contactId).update(updates);
  }

  Future<void> deleteContact(String contactId) async {
    final uid = _currentUid;
    await _contactsCollection(uid).doc(contactId).delete();
  }
}

int _sortContacts(ContactRecord a, ContactRecord b) {
  final aDate =
      a.updatedAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
  final bDate =
      b.updatedAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
  return bDate.compareTo(aDate);
}
