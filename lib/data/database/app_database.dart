import 'dart:convert';
import 'package:animations_in_flutter/core/constants.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../model/trip.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  Future<Database>? _database;

  Future<Database> get database async {
    return _database ??= _initDatabase();
  }

  Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, AppConstants.dbName);
    try {
      return await openDatabase(
        path,
        version: AppConstants.dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onDowngrade: _onDowngrade,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
      );
    } catch (e) {
      await deleteDatabase(path);
      return await openDatabase(
        path,
        version: AppConstants.dbVersion,
        onCreate: _onCreate,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tripsTable} (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        price REAL NOT NULL,
        nights INTEGER NOT NULL,
        image_path TEXT NOT NULL DEFAULT '',
        image_paths TEXT NOT NULL DEFAULT '[]',
        date TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        is_liked INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        category TEXT NOT NULL DEFAULT 'other',
        rating REAL NOT NULL DEFAULT 0.0,
        currency TEXT NOT NULL DEFAULT 'USD',
        reminder_date TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE ${AppConstants.expensesTable} (
        id TEXT PRIMARY KEY,
        trip_id TEXT NOT NULL,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL DEFAULT 'other',
        FOREIGN KEY (trip_id) REFERENCES ${AppConstants.tripsTable}(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE ${AppConstants.checklistTable} (
        id TEXT PRIMARY KEY,
        trip_id TEXT NOT NULL,
        title TEXT NOT NULL,
        is_checked INTEGER NOT NULL DEFAULT 0,
        category TEXT NOT NULL DEFAULT 'general',
        FOREIGN KEY (trip_id) REFERENCES ${AppConstants.tripsTable}(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE ${AppConstants.journalTable} (
        id TEXT PRIMARY KEY,
        trip_id TEXT NOT NULL,
        date TEXT NOT NULL,
        title TEXT NOT NULL,
        text TEXT NOT NULL DEFAULT '',
        image_paths TEXT NOT NULL DEFAULT '[]',
        FOREIGN KEY (trip_id) REFERENCES ${AppConstants.tripsTable}(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    // All schema changes are additive (new columns). Old code safely ignores
    // extra columns, so no data migration is needed.
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _addColumnIfNotExists(
        db,
        AppConstants.tripsTable,
        'image_paths',
        "TEXT NOT NULL DEFAULT '[]'",
      );
      await _addColumnIfNotExists(
        db,
        AppConstants.tripsTable,
        'category',
        "TEXT NOT NULL DEFAULT 'other'",
      );
      await _addColumnIfNotExists(
        db,
        AppConstants.tripsTable,
        'rating',
        'REAL NOT NULL DEFAULT 0.0',
      );

      final rows = await db.query(AppConstants.tripsTable);
      final batch = db.batch();
      for (final row in rows) {
        final oldPath = row['image_path'] as String? ?? '';
        final paths = oldPath.isNotEmpty ? jsonEncode([oldPath]) : '[]';
        batch.update(
          AppConstants.tripsTable,
          {'image_paths': paths},
          where: 'id = ?',
          whereArgs: [row['id']],
        );
      }
      await batch.commit(noResult: true);
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${AppConstants.expensesTable} (
          id TEXT PRIMARY KEY,
          trip_id TEXT NOT NULL,
          title TEXT NOT NULL,
          amount REAL NOT NULL,
          category TEXT NOT NULL DEFAULT 'other',
          FOREIGN KEY (trip_id) REFERENCES ${AppConstants.tripsTable}(id) ON DELETE CASCADE
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${AppConstants.checklistTable} (
          id TEXT PRIMARY KEY,
          trip_id TEXT NOT NULL,
          title TEXT NOT NULL,
          is_checked INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (trip_id) REFERENCES ${AppConstants.tripsTable}(id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 4) {
      await _addColumnIfNotExists(
        db,
        AppConstants.tripsTable,
        'currency',
        "TEXT NOT NULL DEFAULT 'USD'",
      );
    }
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${AppConstants.journalTable} (
          id TEXT PRIMARY KEY,
          trip_id TEXT NOT NULL,
          date TEXT NOT NULL,
          title TEXT NOT NULL,
          text TEXT NOT NULL DEFAULT '',
          image_paths TEXT NOT NULL DEFAULT '[]',
          FOREIGN KEY (trip_id) REFERENCES ${AppConstants.tripsTable}(id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 6) {
      await _addColumnIfNotExists(
        db,
        AppConstants.tripsTable,
        'reminder_date',
        'TEXT',
      );
    }
    if (oldVersion < 7) {
      await _addColumnIfNotExists(
        db,
        AppConstants.tripsTable,
        'reminder_date',
        'TEXT',
      );
    }
    if (oldVersion < 8) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${AppConstants.expensesTable} (
          id TEXT PRIMARY KEY,
          trip_id TEXT NOT NULL,
          title TEXT NOT NULL,
          amount REAL NOT NULL,
          category TEXT NOT NULL DEFAULT 'other',
          FOREIGN KEY (trip_id) REFERENCES ${AppConstants.tripsTable}(id) ON DELETE CASCADE
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${AppConstants.checklistTable} (
          id TEXT PRIMARY KEY,
          trip_id TEXT NOT NULL,
          title TEXT NOT NULL,
          is_checked INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (trip_id) REFERENCES ${AppConstants.tripsTable}(id) ON DELETE CASCADE
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${AppConstants.journalTable} (
          id TEXT PRIMARY KEY,
          trip_id TEXT NOT NULL,
          date TEXT NOT NULL,
          title TEXT NOT NULL,
          text TEXT NOT NULL DEFAULT '',
          image_paths TEXT NOT NULL DEFAULT '[]',
          FOREIGN KEY (trip_id) REFERENCES ${AppConstants.tripsTable}(id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 9) {
      await _addColumnIfNotExists(
        db,
        AppConstants.checklistTable,
        'category',
        "TEXT NOT NULL DEFAULT 'general'",
      );
    }
  }

  Future<void> _addColumnIfNotExists(
    Database db,
    String table,
    String column,
    String type,
  ) async {
    try {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $type');
    } catch (_) {
      // Column already exists — safe to ignore
    }
  }

  Future<int> insertTrip(Trip trip) async {
    final db = await database;
    return await db.insert(AppConstants.tripsTable, trip.toMap());
  }

  Future<int> updateTrip(Trip trip) async {
    final db = await database;
    return await db.update(
      AppConstants.tripsTable,
      trip.toMap(),
      where: 'id = ?',
      whereArgs: [trip.id],
    );
  }

  Future<int> deleteTrip(String id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tripsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Trip>> getAllTrips() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tripsTable,
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Trip.fromMap(map)).toList();
  }

  Future<Trip?> getTripById(String id) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tripsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Trip.fromMap(maps.first);
  }

  Future<void> toggleLike(String id) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE ${AppConstants.tripsTable} SET is_liked = CASE WHEN is_liked = 0 THEN 1 ELSE 0 END WHERE id = ?',
      [id],
    );
  }

  Future<int> getTripsCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.tripsTable}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> insertTripsBatch(List<Trip> trips) async {
    final db = await database;
    final batch = db.batch();
    for (final trip in trips) {
      batch.insert(AppConstants.tripsTable, trip.toMap());
    }
    await batch.commit(noResult: true);
  }
}
