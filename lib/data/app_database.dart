import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Se encarga solo de abrir/crear la base de datos SQLite (Singleton).
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'diary.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE entries(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            image_path TEXT,
            latitude REAL,
            longitude REAL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }
}