# Database Helper

**File**: `lib/core/database/database_helper.dart`

## Purpose

Manages SQLite database lifecycle including:
- Database initialization
- Table creation
- Schema migrations between versions
- Safe column addition without data loss

## Key Features

- **Singleton Pattern**: Single database instance across the app
- **Version Management**: Current version is 5
- **Safe Migrations**: Uses `ALTER TABLE ADD COLUMN` - never drops data
- **Error Handling**: Gracefully handles existing columns

## Database Schema

### Categories Table
```sql
CREATE TABLE categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  name_korean TEXT,
  image_path TEXT
)
```

### Vocabularies Table
```sql
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
```

## Migration History

| Version | Changes |
|---------|---------|
| 1 | Initial tables (id, name, word, meaning) |
| 2 | Added name_korean, image_path to categories |
| 3 | Added SRS fields (familiarity, streak, next_review, etc.) |
| 4 | Added example_meaning, note to vocabularies |
| 5 | Future-proofing |

## Usage

```dart
final dbHelper = DatabaseHelper();
final db = await dbHelper.database;
// Use db.rawQuery(), db.insert(), etc.
```

## Migration Strategy

Always use `_addColumnIfNotExists()` for safe migrations:
- Checks if column exists before adding
- Catches exceptions gracefully
- Never drops existing data

## Debug Method

`resetDatabase()` - Deletes and recreates database (use with caution!)
