import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class QuoteDatabase {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'quote_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE quotes(id INTEGER PRIMARY KEY, text TEXT, author TEXT)',
        );
      },
    );
  }

  Future<void> insertQuote(Map<String, dynamic> quote) async {
    final db = await database;
    await db.insert('quotes', quote,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getQuotes() async {
    final db = await database;
    return db.query('quotes');
  }
}
