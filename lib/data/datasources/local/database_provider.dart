import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  static final DatabaseProvider instance = DatabaseProvider._internal();
  DatabaseProvider._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    await initDB();
    return _database!;
  }

  Future<void> initDB() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'vidian_stream.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE playback_history(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            contentId TEXT NOT NULL,
            startedAt INTEGER NOT NULL,
            positionMillis INTEGER NOT NULL,
            durationMillis INTEGER
          );
        ''');
      },
    );
  }

  Future<int> insertHistory(Map<String, Object?> row) async {
    final db = await database;
    return await db.insert('playback_history', row);
  }

  Future<List<Map<String, Object?>>> getHistory({int limit = 100}) async {
    final db = await database;
    return await db.query('playback_history', orderBy: 'startedAt DESC', limit: limit);
  }
}