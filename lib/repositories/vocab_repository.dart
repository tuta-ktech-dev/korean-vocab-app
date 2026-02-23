import '../core/database/database_helper.dart';
import '../models/vocab.dart';

class VocabRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Vocab>> getAllVocabs() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('vocabularies');
    return List.generate(maps.length, (i) => Vocab.fromMap(maps[i]));
  }

  Future<List<Vocab>> getVocabsByCategory(String categoryId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vocabularies',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return List.generate(maps.length, (i) => Vocab.fromMap(maps[i]));
  }

  Future<Vocab?> getVocab(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'vocabularies',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Vocab.fromMap(maps.first);
    }
    return null;
  }

  Future<void> insertVocab(Vocab vocab) async {
    final db = await _dbHelper.database;
    await db.insert('vocabularies', vocab.toMap());
  }

  Future<void> updateVocab(Vocab vocab) async {
    final db = await _dbHelper.database;
    await db.update(
      'vocabularies',
      vocab.toMap(),
      where: 'id = ?',
      whereArgs: [vocab.id],
    );
  }

  Future<void> deleteVocab(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'vocabularies',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> incrementReviewCount(String id) async {
    final db = await _dbHelper.database;
    await db.rawUpdate(
      'UPDATE vocabularies SET review_count = review_count + 1 WHERE id = ?',
      [id],
    );
  }
}
