import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'local_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pending_requests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        endpoint TEXT NOT NULL,
        payload TEXT NOT NULL
      )
    ''');
  }

  Future<void> insertPendingRequest(String endpoint, String payload) async {
    final db = await database;
    await db.insert('pending_requests', {
      'endpoint': endpoint,
      'payload': payload,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingRequests() async {
    final db = await database;
    return await db.query('pending_requests');
  }

  Future<void> deletePendingRequest(int id) async {
    final db = await database;
    await db.delete('pending_requests', where: 'id = ?', whereArgs: [id]);
  }
}
