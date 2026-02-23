import 'package:flutter_test/flutter_test.dart';
import 'package:korean_vocab/models/vocab.dart';

void main() {
  group('Vocab Model', () {
    test('should create vocab from map correctly', () {
      final now = DateTime.now();
      final map = {
        'id': '1',
        'word': '사과',
        'meaning': 'Quả táo',
        'example': '사과를 먹어요',
        'example_meaning': 'Tôi ăn táo',
        'note': 'Danh từ, thường dùng với 를/을',
        'category_id': 'cat1',
        'image_path': '/path/to/image.jpg',
        'created_at': now.toIso8601String(),
        'familiarity': 2,
        'streak': 3,
        'next_review': now.add(const Duration(days: 3)).toIso8601String(),
        'total_reviews': 10,
        'correct_count': 8,
        'accuracy': 0.8,
        'last_reviewed': now.toIso8601String(),
        'time_spent': 300,
      };
      
      final vocab = Vocab.fromMap(map);
      
      expect(vocab.id, '1');
      expect(vocab.word, '사과');
      expect(vocab.meaning, 'Quả táo');
      expect(vocab.example, '사과를 먹어요');
      expect(vocab.exampleMeaning, 'Tôi ăn táo');
      expect(vocab.note, 'Danh từ, thường dùng với 를/을');
      expect(vocab.categoryId, 'cat1');
      expect(vocab.imagePath, '/path/to/image.jpg');
      expect(vocab.familiarity, 2);
      expect(vocab.streak, 3);
      expect(vocab.totalReviews, 10);
      expect(vocab.correctCount, 8);
      expect(vocab.accuracy, 0.8);
      expect(vocab.timeSpent, 300);
    });

    test('should convert vocab to map correctly', () {
      final now = DateTime.now();
      final vocab = Vocab(
        id: '1',
        word: '사과',
        meaning: 'Quả táo',
        example: '사과를 먹어요',
        exampleMeaning: 'Tôi ăn táo',
        note: 'Ghi chú',
        categoryId: 'cat1',
        imagePath: '/path/to/image.jpg',
        createdAt: now,
        familiarity: 2,
        streak: 3,
        nextReview: now.add(const Duration(days: 3)),
        totalReviews: 10,
        correctCount: 8,
        accuracy: 0.8,
        lastReviewed: now,
        timeSpent: 300,
      );
      
      final map = vocab.toMap();
      
      expect(map['id'], '1');
      expect(map['word'], '사과');
      expect(map['meaning'], 'Quả táo');
      expect(map['example'], '사과를 먹어요');
      expect(map['example_meaning'], 'Tôi ăn táo');
      expect(map['note'], 'Ghi chú');
      expect(map['familiarity'], 2);
      expect(map['accuracy'], 0.8);
    });

    test('should handle null values', () {
      final now = DateTime.now();
      final map = {
        'id': '1',
        'word': '사과',
        'meaning': 'Quả táo',
        'category_id': 'cat1',
        'created_at': now.toIso8601String(),
        'example': null,
        'example_meaning': null,
        'note': null,
        'image_path': null,
        'next_review': null,
        'last_reviewed': null,
      };
      
      final vocab = Vocab.fromMap(map);
      
      expect(vocab.example, null);
      expect(vocab.exampleMeaning, null);
      expect(vocab.note, null);
      expect(vocab.imagePath, null);
      expect(vocab.nextReview, null);
      expect(vocab.lastReviewed, null);
    });

    test('should use default values for SRS fields', () {
      final now = DateTime.now();
      final map = {
        'id': '1',
        'word': '사과',
        'meaning': 'Quả táo',
        'category_id': 'cat1',
        'created_at': now.toIso8601String(),
      };
      
      final vocab = Vocab.fromMap(map);
      
      expect(vocab.familiarity, 0);
      expect(vocab.streak, 0);
      expect(vocab.totalReviews, 0);
      expect(vocab.correctCount, 0);
      expect(vocab.accuracy, 0.0);
      expect(vocab.timeSpent, 0);
    });

    test('copyWith should update fields', () {
      final vocab = Vocab(
        id: '1',
        word: '사과',
        meaning: 'Quả táo',
        categoryId: 'cat1',
        createdAt: DateTime.now(),
        familiarity: 1,
        streak: 2,
      );
      
      final updated = vocab.copyWith(
        familiarity: 3,
        streak: 5,
        totalReviews: 10,
      );
      
      expect(updated.id, '1');
      expect(updated.word, '사과');
      expect(updated.familiarity, 3);
      expect(updated.streak, 5);
      expect(updated.totalReviews, 10);
    });

    test('copyWith should update nextReview and lastReviewed', () {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      
      final vocab = Vocab(
        id: '1',
        word: '사과',
        meaning: 'Quả táo',
        categoryId: 'cat1',
        createdAt: now,
      );
      
      final updated = vocab.copyWith(
        nextReview: tomorrow,
        lastReviewed: now,
      );
      
      expect(updated.nextReview, tomorrow);
      expect(updated.lastReviewed, now);
    });
  });
}
