import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:cv_bank/core/error/exceptions.dart';
import '../models/person_model.dart';

/// Two caches with different jobs:
///   - a sqflite table so the people list opens offline
///   - files on disk so a CV opened once opens instantly next time
abstract interface class PersonLocalDataSource {
  Future<List<PersonModel>> cachedPeople({String? categoryId, int limit});
  Future<void> cachePeople(List<PersonModel> people);
  Future<void> removeCached(String id);
  Future<void> clear();

  Future<File?> cachedFile(String storagePath);
  Future<File> writeFile(String storagePath, List<int> bytes);
}

class PersonSqfliteDataSource implements PersonLocalDataSource {
  Database? _db;

  Future<Database> get _database async {
    if (_db != null) return _db!;

    final dir = await getApplicationDocumentsDirectory();
    _db = await openDatabase(
      p.join(dir.path, 'cv_bank_cache.db'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE people (
            id TEXT PRIMARY KEY,
            full_name TEXT NOT NULL,
            phone TEXT NOT NULL,
            category_id TEXT,
            category_name TEXT,
            status TEXT NOT NULL,
            relationship TEXT NOT NULL,
            received_on INTEGER NOT NULL,
            document_count INTEGER NOT NULL DEFAULT 0,
            cached_at INTEGER NOT NULL
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_people_category ON people(category_id)',
        );
      },
    );
    return _db!;
  }

  @override
  Future<List<PersonModel>> cachedPeople({
    String? categoryId,
    int limit = 50,
  }) async {
    try {
      final db = await _database;
      final rows = await db.query(
        'people',
        where: categoryId == null ? null : 'category_id = ?',
        whereArgs: categoryId == null ? null : [categoryId],
        orderBy: 'received_on DESC',
        limit: limit,
      );
      return rows.map(PersonModel.fromCache).toList();
    } catch (e) {
      throw CacheException('Could not read saved people.', cause: e);
    }
  }

  @override
  Future<void> cachePeople(List<PersonModel> people) async {
    if (people.isEmpty) return;
    try {
      final db = await _database;
      final batch = db.batch();
      for (final person in people) {
        batch.insert(
          'people',
          person.toCache(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (_) {
      // Caching is best effort. A failure here must never break the
      // request that succeeded.
    }
  }

  @override
  Future<void> removeCached(String id) async {
    try {
      final db = await _database;
      await db.delete('people', where: 'id = ?', whereArgs: [id]);
    } catch (_) {}
  }

  @override
  Future<void> clear() async {
    try {
      final db = await _database;
      await db.delete('people');
      final dir = await _fileCacheDir();
      if (dir.existsSync()) await dir.delete(recursive: true);
    } catch (_) {}
  }

  // -------------------------------------------------------------------
  // Files
  // -------------------------------------------------------------------

  Future<Directory> _fileCacheDir() async {
    final base = await getApplicationDocumentsDirectory();
    return Directory(p.join(base.path, 'documents'));
  }

  /// Storage paths contain slashes, so they are flattened into a
  /// single filename.
  String _localName(String storagePath) => storagePath.replaceAll('/', '_');

  @override
  Future<File?> cachedFile(String storagePath) async {
    try {
      final dir = await _fileCacheDir();
      final file = File(p.join(dir.path, _localName(storagePath)));
      return file.existsSync() ? file : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<File> writeFile(String storagePath, List<int> bytes) async {
    try {
      final dir = await _fileCacheDir();
      if (!dir.existsSync()) dir.createSync(recursive: true);

      final file = File(p.join(dir.path, _localName(storagePath)));
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } catch (e) {
      throw CacheException('Could not save that file.', cause: e);
    }
  }
}
