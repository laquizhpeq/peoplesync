import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:peoplesync/features/contacts/models/contact_record.dart';
import 'package:sqflite/sqflite.dart';

class LocalContactsCacheService {
  Database? _database;

  Future<List<ContactRecord>> readContacts(String uid) async {
    if (kIsWeb) return const [];
    final database = await _getDatabase();
    final rows = await database.query(
      'contacts_cache',
      where: 'owner_uid = ?',
      whereArgs: [uid],
      orderBy: 'sort_timestamp DESC',
    );

    return rows.map((row) {
      final payload = row['payload'] as String? ?? '{}';
      final decoded = jsonDecode(payload);
      return ContactRecord.fromJsonMap(
        Map<String, dynamic>.from(decoded as Map),
      );
    }).toList();
  }

  Future<void> replaceContacts(String uid, List<ContactRecord> contacts) async {
    if (kIsWeb) return;
    final database = await _getDatabase();
    final batch = database.batch();

    batch.delete('contacts_cache', where: 'owner_uid = ?', whereArgs: [uid]);

    for (final contact in contacts) {
      batch.insert('contacts_cache', {
        'owner_uid': uid,
        'contact_id': contact.id,
        'payload': jsonEncode(contact.toJsonMap()),
        'sort_timestamp': _resolveSortTimestamp(contact),
      });
    }

    await batch.commit(noResult: true);
  }

  Future<void> clearForUser(String uid) async {
    if (kIsWeb) return;
    final database = await _getDatabase();
    await database.delete(
      'contacts_cache',
      where: 'owner_uid = ?',
      whereArgs: [uid],
    );
  }

  Future<Database> _getDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite local cache is not available on web.');
    }
    final existing = _database;
    if (existing != null) return existing;

    final databasesPath = await getDatabasesPath();
    final databasePath = path.join(databasesPath, 'peoplesync_cache.db');

    _database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE contacts_cache (
            owner_uid TEXT NOT NULL,
            contact_id TEXT NOT NULL,
            payload TEXT NOT NULL,
            sort_timestamp INTEGER NOT NULL,
            PRIMARY KEY (owner_uid, contact_id)
          )
        ''');
      },
    );

    return _database!;
  }

  int _resolveSortTimestamp(ContactRecord contact) {
    return (contact.updatedAt ?? contact.createdAt ?? DateTime(1970))
        .millisecondsSinceEpoch;
  }
}
