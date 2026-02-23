import 'dart:convert';
import 'package:flutter/services.dart';
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

    // Seed if empty (handles both new and upgraded-empty DBs)
    final count = Sqflite.firstIntValue(
      await _database!.rawQuery('SELECT COUNT(*) FROM categories'),
    );
    if (count == 0 || count == null) {
      await _seedDatabase(_database!);
    }

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

    // Seed initial data
    await _seedDatabase(db);
  }

  /// Seeds the database with initial TOPIK I vocabulary from JSON
  Future<void> _seedDatabase(Database db) async {
    try {
      final String response = await rootBundle.loadString(
        'assets/seed/topik_i_vocab.json',
      );
      final data = json.decode(response);
      final List themes = data['themes'];

      for (int i = 0; i < themes.length; i++) {
        final theme = themes[i];
        final categoryId = 'seed_cat_$i';

        await db.insert('categories', {
          'id': categoryId,
          'name': theme['name'],
          'name_korean': null,
          'image_path': null,
        });

        final List words = theme['words'];
        for (int j = 0; j < words.length; j++) {
          final word = words[j];
          await db.insert('vocabularies', {
            'id': 'seed_vocab_${i}_$j',
            'word': word['word'],
            'pronunciation': word['pronunciation'],
            'meaning': word['meaning'],
            'category_id': categoryId,
            'created_at': DateTime.now().toIso8601String(),
            'familiarity': 0,
            'streak': 0,
            'total_reviews': 0,
            'correct_count': 0,
            'accuracy': 0.0,
            'time_spent': 0,
          });
        }
      }
    } catch (e) {
      // Log error in debug mode
      print('Error seeding database: $e');
    }
  }

  /// Handles database migrations between versions
  /// Uses safe column addition - never drops existing data
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _addColumnIfNotExists(db, 'categories', 'name_korean', 'TEXT');
      await _addColumnIfNotExists(db, 'categories', 'image_path', 'TEXT');
    }

    if (oldVersion < 3) {
      await _addColumnIfNotExists(
        db,
        'vocabularies',
        'familiarity',
        'INTEGER DEFAULT 0',
      );
      await _addColumnIfNotExists(
        db,
        'vocabularies',
        'streak',
        'INTEGER DEFAULT 0',
      );
      await _addColumnIfNotExists(db, 'vocabularies', 'next_review', 'TEXT');
      await _addColumnIfNotExists(
        db,
        'vocabularies',
        'total_reviews',
        'INTEGER DEFAULT 0',
      );
      await _addColumnIfNotExists(
        db,
        'vocabularies',
        'correct_count',
        'INTEGER DEFAULT 0',
      );
      await _addColumnIfNotExists(
        db,
        'vocabularies',
        'accuracy',
        'REAL DEFAULT 0.0',
      );
      await _addColumnIfNotExists(db, 'vocabularies', 'last_reviewed', 'TEXT');
      await _addColumnIfNotExists(
        db,
        'vocabularies',
        'time_spent',
        'INTEGER DEFAULT 0',
      );
    }

    if (oldVersion < 4) {
      await _addColumnIfNotExists(
        db,
        'vocabularies',
        'example_meaning',
        'TEXT',
      );
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

  /// Export all data to JSON format
  Future<Map<String, dynamic>> exportData() async {
    final db = await database;

    // Get all categories
    final categories = await db.query('categories');

    // Get all vocabularies
    final vocabularies = await db.query('vocabularies');

    return {
      'export_date': DateTime.now().toIso8601String(),
      'app_version': '3.9.0',
      'categories': categories,
      'vocabularies': vocabularies,
    };
  }

  /// Import data from JSON format
  /// Returns: {'success': true/false, 'imported_categories': n, 'imported_vocabularies': n}
  Future<Map<String, dynamic>> importData(Map<String, dynamic> data) async {
    final db = await database;

    int importedCategories = 0;
    int importedVocabularies = 0;

    await db.transaction((txn) async {
      // Clear existing data
      await txn.delete('vocabularies');
      await txn.delete('categories');

      final batch = txn.batch();

      // Import categories
      final categories = data['categories'] as List<dynamic>?;
      if (categories != null) {
        for (final cat in categories) {
          final categoryMap = Map<String, dynamic>.from(cat);
          batch.insert('categories', categoryMap);
          importedCategories++;
        }
      }

      // Import vocabularies
      final vocabularies = data['vocabularies'] as List<dynamic>?;
      if (vocabularies != null) {
        for (final vocab in vocabularies) {
          final vocabMap = Map<String, dynamic>.from(vocab);
          batch.insert('vocabularies', vocabMap);
          importedVocabularies++;
        }
      }

      await batch.commit(noResult: true);
    });

    return {
      'success': true,
      'imported_categories': importedCategories,
      'imported_vocabularies': importedVocabularies,
    };
  }
}
