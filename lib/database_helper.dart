import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'main.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'watchlist.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE watch_items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            date TEXT NOT NULL,
            point INTEGER NOT NULL DEFAULT 0,
            status TEXT NOT NULL,
            isFavorite INTEGER NOT NULL DEFAULT 0,
            genre TEXT NOT NULL,
            platform TEXT NOT NULL DEFAULT ''
          )
        ''');
      },
    );
  }

  static Future<List<WatchItem>> getAll() async {
    final db = await database;
    final result = await db.query('watch_items', orderBy: 'id DESC');
    return result.map((map) => WatchItem.fromMap(map)).toList();
  }

  static Future<int> insert(WatchItem item) async {
    final db = await database;
    final map = item.toMap();
    map.remove('id');
    return await db.insert('watch_items', map);
  }

  static Future<int> update(WatchItem item) async {
    final db = await database;
    final map = item.toMap();
    map.remove('id');
    return await db.update(
      'watch_items',
      map,
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  static Future<int> delete(int id) async {
    final db = await database;
    return await db.delete('watch_items', where: 'id = ?', whereArgs: [id]);
  }
}
