import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// DatabaseHelper manages SQLite database operations with proper migrations.
/// 
/// This class handles:
/// - Database initialization and versioning
/// - Table creation for categories and vocabularies
/// - Safe migrations when upgrading database versions
/// - CRUD operations wrapper
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  /// Gets the database instance, creating it if necessary
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the database with proper versioning
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'korean_vocab.db');
    
    return await openDatabase(
      path,
      version: 6, // Added pronunciation field
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  /// Creates all tables when database is first created
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
        pronunciation TEXT,
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

  /// Handles database migrations between versions
  /// Uses safe column addition - never drops existing data
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _addColumnIfNotExists(db, 'categories', 'name_korean', 'TEXT');
      await _addColumnIfNotExists(db, 'categories', 'image_path', 'TEXT');
    }
    
    if (oldVersion < 3) {
      await _addColumnIfNotExists(db, 'vocabularies', 'familiarity', 'INTEGER DEFAULT 0');
      await _addColumnIfNotExists(db, 'vocabularies', 'streak', 'INTEGER DEFAULT 0');
      await _addColumnIfNotExists(db, 'vocabularies', 'next_review', 'TEXT');
      await _addColumnIfNotExists(db, 'vocabularies', 'total_reviews', 'INTEGER DEFAULT 0');
      await _addColumnIfNotExists(db, 'vocabularies', 'correct_count', 'INTEGER DEFAULT 0');
      await _addColumnIfNotExists(db, 'vocabularies', 'accuracy', 'REAL DEFAULT 0.0');
      await _addColumnIfNotExists(db, 'vocabularies', 'last_reviewed', 'TEXT');
      await _addColumnIfNotExists(db, 'vocabularies', 'time_spent', 'INTEGER DEFAULT 0');
    }
    
    if (oldVersion < 4) {
      await _addColumnIfNotExists(db, 'vocabularies', 'example_meaning', 'TEXT');
      await _addColumnIfNotExists(db, 'vocabularies', 'note', 'TEXT');
    }
    
    if (oldVersion < 6) {
      // Added pronunciation field
      await _addColumnIfNotExists(db, 'vocabularies', 'pronunciation', 'TEXT');
    }
  }
  
  /// Safely adds a column if it doesn't exist
  /// Catches exceptions if column already exists
  Future<void> _addColumnIfNotExists(
    Database db, 
    String table, 
    String column, 
    String type,
  ) async {
    try {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $type');
    } catch (e) {
      // Column already exists or other error - safe to ignore
    }
  }
  
  /// Resets database by deleting and recreating (for debugging only)
  Future<void> resetDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'korean_vocab.db');
    await deleteDatabase(path);
    _database = null;
    await database;
  }
}
