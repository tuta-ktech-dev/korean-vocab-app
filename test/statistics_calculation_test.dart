import 'package:flutter_test/flutter_test.dart';
import 'package:korean_vocab/models/vocab.dart';

void main() {
  group('Statistics Calculations', () {
    test('should identify difficult words correctly', () {
      final vocabs = [
        Vocab(
          id: '1',
          word: '사과',
          meaning: 'Quả táo',
          categoryId: 'cat1',
          createdAt: DateTime.now(),
          totalReviews: 10,
          correctCount: 3,
          accuracy: 0.3,
        ),
        Vocab(
          id: '2',
          word: '바나나',
          meaning: 'Quả chuối',
          categoryId: 'cat1',
          createdAt: DateTime.now(),
          totalReviews: 10,
          correctCount: 8,
          accuracy: 0.8,
        ),
        Vocab(
          id: '3',
          word: '딸기',
          meaning: 'Quả dâu',
          categoryId: 'cat1',
          createdAt: DateTime.now(),
          totalReviews: 0,
          correctCount: 0,
          accuracy: 0.0,
        ),
      ];

      // Filter words with accuracy < 0.7 and reviewed at least once
      final difficultWords = vocabs
          .where((v) => v.totalReviews > 0 && v.accuracy < 0.7)
          .toList();

      expect(difficultWords.length, 1);
      expect(difficultWords.first.word, '사과');
    });

    test('should calculate total statistics', () {
      final vocabs = [
        Vocab(
          id: '1',
          word: '사과',
          meaning: 'Quả táo',
          categoryId: 'cat1',
          createdAt: DateTime.now(),
          familiarity: 3,
          totalReviews: 10,
          accuracy: 0.9,
        ),
        Vocab(
          id: '2',
          word: '바나나',
          meaning: 'Quả chuối',
          categoryId: 'cat1',
          createdAt: DateTime.now(),
          familiarity: 2,
          totalReviews: 5,
          accuracy: 0.7,
        ),
        Vocab(
          id: '3',
          word: '딸기',
          meaning: 'Quả dâu',
          categoryId: 'cat1',
          createdAt: DateTime.now(),
          familiarity: 0,
          totalReviews: 0,
          accuracy: 0.0,
        ),
      ];

      int mastered = 0;
      int learning = 0;
      int notStarted = 0;
      int totalReviews = 0;
      double totalAccuracy = 0;

      for (final vocab in vocabs) {
        if (vocab.familiarity >= 3) {
          mastered++;
        } else if (vocab.familiarity > 0) {
          learning++;
        } else if (vocab.totalReviews == 0) {
          notStarted++;
        }
        totalReviews += vocab.totalReviews;
        totalAccuracy += vocab.accuracy;
      }

      expect(mastered, 1);
      expect(learning, 1);
      expect(notStarted, 1);
      expect(totalReviews, 15);
      expect((totalAccuracy / vocabs.length * 100).toInt(), 53);
    });

    test('should identify due words for today', () {
      final now = DateTime.now();
      
      final vocabs = [
        Vocab(
          id: '1',
          word: '사과',
          meaning: 'Quả táo',
          categoryId: 'cat1',
          createdAt: now,
          nextReview: now.subtract(const Duration(hours: 1)), // Overdue
        ),
        Vocab(
          id: '2',
          word: '바나나',
          meaning: 'Quả chuối',
          categoryId: 'cat1',
          createdAt: now,
          nextReview: now.add(const Duration(days: 1)), // Tomorrow
        ),
        Vocab(
          id: '3',
          word: '딸기',
          meaning: 'Quả dâu',
          categoryId: 'cat1',
          createdAt: now,
          nextReview: null, // New word
        ),
      ];

      final dueWords = vocabs.where((v) {
        return v.nextReview == null || v.nextReview!.isBefore(now);
      }).toList();

      expect(dueWords.length, 2);
      expect(dueWords.map((v) => v.id).contains('1'), true);
      expect(dueWords.map((v) => v.id).contains('3'), true);
    });
  });
}
