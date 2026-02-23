import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'korean_vocab.db');
    return await openDatabase(
      path,
      version: 3, // Tăng version cho SRS
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        name_korean TEXT,
        image_path TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE vocabularies (
        id TEXT PRIMARY KEY,
        word TEXT NOT NULL,
        meaning TEXT NOT NULL,
        example TEXT,
        example_meaning TEXT,
        note TEXT,
        category_id TEXT NOT NULL,
        image_path TEXT,
        created_at TEXT NOT NULL,
        familiarity INTEGER DEFAULT 0,
        streak INTEGER DEFAULT 0,
        next_review TEXT,
        total_reviews INTEGER DEFAULT 0,
        correct_count INTEGER DEFAULT 0,
        accuracy REAL DEFAULT 0.0,
        last_reviewed TEXT,
        time_spent INTEGER DEFAULT 0,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Migration cho SRS fields
      await db.execute('ALTER TABLE vocabularies ADD COLUMN familiarity INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE vocabularies ADD COLUMN streak INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE vocabularies ADD COLUMN next_review TEXT');
      await db.execute('ALTER TABLE vocabularies ADD COLUMN total_reviews INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE vocabularies ADD COLUMN correct_count INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE vocabularies ADD COLUMN accuracy REAL DEFAULT 0.0');
      await db.execute('ALTER TABLE vocabularies ADD COLUMN last_reviewed TEXT');
      await db.execute('ALTER TABLE vocabularies ADD COLUMN time_spent INTEGER DEFAULT 0');
    }
  }
}
