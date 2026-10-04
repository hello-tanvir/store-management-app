import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../data/models/store_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('store.db');

    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(
      Database db,
      int version,
      ) async {
    await db.execute('''
      CREATE TABLE stores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        store_name TEXT NOT NULL,
        owner_name TEXT NOT NULL,
        mobile_number TEXT NOT NULL,
        store_type TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        address TEXT,
        created_at TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // Insert Store
  Future<int> insertStore(
      StoreModel store,
      ) async {
    final db = await database;

    return await db.insert(
      'stores',
      store.toMap(),
    );
  }

  // Get All Stores
  Future<List<StoreModel>> getStores() async {
    final db = await database;

    final result = await db.query(
      'stores',
      orderBy: 'id DESC',
    );

    return result.map((map) {
      return StoreModel.fromMap(map);
    }).toList();
  }

  // Get Unsynced Stores
  Future<List<StoreModel>> getUnsyncedStores() async {
    final db = await database;

    final result = await db.query(
      'stores',
      where: 'is_synced = ?',
      whereArgs: [0],
      orderBy: 'id ASC',
    );

    return result.map((map) {
      return StoreModel.fromMap(map);
    }).toList();
  }

  // Mark Store as Synced
  Future<int> markAsSynced(
      int id,
      ) async {
    final db = await database;

    return await db.update(
      'stores',
      {
        'is_synced': 1,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateAddress(
      int id,
      String address,
      ) async {
    final db = await database;

    return await db.update(
      'stores',
      {
        'address': address,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateStore(
      int id,
      Map<String, dynamic> data,
      ) async {
    final db = await database;

    return await db.update(
      'stores',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteStore(
      int id,
      ) async {
    final db = await database;

    return await db.delete(
      'stores',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}