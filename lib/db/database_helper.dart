import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:my_form_app/models/form_response.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const _databaseName = 'form_responses.db';
  static const _databaseVersion = 6;
  static const tableResponses = 'responses';

  Database? _database;
  static bool _sqfliteInitialized = false;

  Future<void> _ensureDatabaseFactory() async {
    if (_sqfliteInitialized) return;
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _sqfliteInitialized = true;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    await _ensureDatabaseFactory();
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);
    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableResponses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        dob TEXT NOT NULL,
        age INTEGER NOT NULL,
        gender TEXT,
        yearsOfExperience INTEGER DEFAULT 0,
        rating INTEGER,
        agreed INTEGER DEFAULT 0,
        photoPath TEXT,
        resumePath TEXT,
        languages TEXT DEFAULT '[]',
        heightFeet INTEGER DEFAULT 0,
        heightInches INTEGER DEFAULT 0,
        weight REAL DEFAULT 0.0,
        synced INTEGER DEFAULT 0,
        firestoreId TEXT,
        createdAt TEXT,
        voiceRecordingPath TEXT,
        transcriptionOriginal TEXT,
        transcriptionEnglish TEXT,
        detectedLanguage TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE $tableResponses ADD COLUMN age INTEGER DEFAULT 0',
      );
      await db.execute('ALTER TABLE $tableResponses ADD COLUMN gender TEXT');
      await db.execute(
        'ALTER TABLE $tableResponses ADD COLUMN rating INTEGER DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE $tableResponses ADD COLUMN agreed INTEGER DEFAULT 0',
      );
    }
    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE $tableResponses ADD COLUMN email TEXT DEFAULT ""',
      );
      await db.execute(
        'ALTER TABLE $tableResponses ADD COLUMN yearsOfExperience INTEGER DEFAULT 0',
      );
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE $tableResponses ADD COLUMN photoPath TEXT');
      await db.execute(
        'ALTER TABLE $tableResponses ADD COLUMN resumePath TEXT',
      );
      await db.execute(
        'ALTER TABLE $tableResponses ADD COLUMN languages TEXT DEFAULT "[]"',
      );
      await db.execute(
        'ALTER TABLE $tableResponses ADD COLUMN heightFeet INTEGER DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE $tableResponses ADD COLUMN heightInches INTEGER DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE $tableResponses ADD COLUMN weight REAL DEFAULT 0.0',
      );
    }
    if (oldVersion < 5) {
      await db.execute(
        'ALTER TABLE $tableResponses ADD COLUMN synced INTEGER DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE $tableResponses ADD COLUMN firestoreId TEXT',
      );
      await db.execute(
        'ALTER TABLE $tableResponses ADD COLUMN createdAt TEXT',
      );
    }
    if (oldVersion < 6) {
      await db.execute(
        'ALTER TABLE $tableResponses ADD COLUMN voiceRecordingPath TEXT',
      );
      await db.execute(
        'ALTER TABLE $tableResponses ADD COLUMN transcriptionOriginal TEXT',
      );
      await db.execute(
        'ALTER TABLE $tableResponses ADD COLUMN transcriptionEnglish TEXT',
      );
      await db.execute(
        'ALTER TABLE $tableResponses ADD COLUMN detectedLanguage TEXT',
      );
    }
  }

  Future<int> insertResponse(FormResponse response) async {
    final db = await database;
    final map = response.toMap();
    map.remove('id');
    return db.insert(tableResponses, map);
  }

  Future<List<FormResponse>> fetchResponses() async {
    final db = await database;
    final rows = await db.query(tableResponses, orderBy: 'id DESC');
    return rows.map(FormResponse.fromMap).toList();
  }

  Future<List<FormResponse>> getUnsyncedResponses() async {
    final db = await database;
    final rows = await db.query(
      tableResponses,
      where: 'synced = ?',
      whereArgs: [0],
      orderBy: 'id ASC',
    );
    return rows.map(FormResponse.fromMap).toList();
  }

  Future<int> markAsSynced(int localId, String firestoreId) async {
    final db = await database;
    return db.update(
      tableResponses,
      {
        'synced': 1,
        'firestoreId': firestoreId,
      },
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  Future<int> deleteResponse(int id) async {
    final db = await database;
    return db.delete(tableResponses, where: 'id = ?', whereArgs: [id]);
  }
}
