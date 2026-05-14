import 'package:cloud_firestore/cloud_firestore.dart';

class ContactEvent {
  final String id;
  final String type;
  final String? note;
  final DateTime? createdAt;
  final Map<String, dynamic> meta;

  const ContactEvent({
    this.id = '',
    required this.type,
    this.note,
    this.createdAt,
    this.meta = const {},
  });

  factory ContactEvent.fromMap(Map<String, dynamic> map, String id) {
    return ContactEvent(
      id: id,
      type: map['type'] as String? ?? 'updated',
      note: map['note'] as String?,
      createdAt: (map['created_at'] as Timestamp?)?.toDate(),
      meta: Map<String, dynamic>.from(map['meta'] as Map? ?? const {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'note': note,
      'created_at': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
      'meta': meta,
    };
  }
}
