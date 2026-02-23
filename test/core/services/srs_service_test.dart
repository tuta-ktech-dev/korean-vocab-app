import 'package:flutter_test/flutter_test.dart';
import 'package:korean_vocab/core/services/srs_service.dart';
import 'package:korean_vocab/models/quiz.dart';
import 'package:korean_vocab/models/vocab.dart';

void main() {
  group('SRSService', () {
    late SRSService srsService;
    
    setUp(() {
      srsService = SRSService();
    });

    group('calculateNextReview', () {
      test('correct answer should increase interval', () {
        final vocab = Vocab(
          id: '1',
          word: '사과',
          meaning: 'Quả táo',
          categoryId: 'cat1',
          createdAt: DateTime.now(),
          familiarity: 1,
          streak: 2,
        );
        
        final result = srsService.calculateNextReview(vocab, QuizResult.correct);
        
        // Should be at least 1 day later (interval for familiarity 1)
        expect(result.isAfter(DateTime.now()), true);
        expect(result.difference(DateTime.now()).inHours, greaterThan(20));
      });

      test('incorrect answer should reset to 10 minutes', () {
        final vocab = Vocab(
          id: '1',
          word: '사과',
          meaning: 'Quả táo',
          categoryId: 'cat1',
          createdAt: DateTime.now(),
          familiarity: 3,
          streak: 5,
        );
        
        final result = srsService.calculateNextReview(vocab, QuizResult.incorrect);
        
        // Should be ~10 minutes later
        final diff = result.difference(DateTime.now()).inMinutes;
        expect(diff, greaterThanOrEqualTo(8)); // Allow some tolerance
        expect(diff, lessThan(15));
      });

      test('hint should schedule for 1 hour later', () {
        final vocab = Vocab(
          id: '1',
          word: '사과',
          meaning: 'Quả táo',
          categoryId: 'cat1',
          createdAt: DateTime.now(),
        );
        
        final result = srsService.calculateNextReview(vocab, QuizResult.hint);
        
        // Should be ~1 hour later
        final diff = result.difference(DateTime.now()).inMinutes;
        expect(diff, greaterThanOrEqualTo(55));
        expect(diff, lessThan(65));
      });

      test('skip should schedule for 30 minutes later', () {
        final vocab = Vocab(
          id: '1',
          word: '사과',
          meaning: 'Quả táo',
          categoryId: 'cat1',
          createdAt: DateTime.now(),
        );
        
        final result = srsService.calculateNextReview(vocab, QuizResult.skip);
        
        // Should be ~30 minutes later
        final diff = result.difference(DateTime.now()).inMinutes;
        expect(diff, greaterThanOrEqualTo(25));
        expect(diff, lessThan(35));
      });

      test('correct with high streak should have longer interval', () {
        final vocabLowStreak = Vocab(
          id: '1',
          word: '사과',
          meaning: 'Quả táo',
          categoryId: 'cat1',
          createdAt: DateTime.now(),
          familiarity: 2,
          streak: 1,
        );
        
        final vocabHighStreak = Vocab(
          id: '2',
          word: '바나나',
          meaning: 'Quả chuối',
          categoryId: 'cat1',
          createdAt: DateTime.now(),
          familiarity: 2,
          streak: 5,
        );
        
        final resultLow = srsService.calculateNextReview(vocabLowStreak, QuizResult.correct);
        final resultHigh = srsService.calculateNextReview(vocabHighStreak, QuizResult.correct);
        
        // High streak should have longer interval
        expect(
          resultHigh.difference(DateTime.now()),
          greaterThan(resultLow.difference(DateTime.now())),
        );
      });
    });

    group('determineQuizMode', () {
      test('new vocab should use flashcard', () {
        final vocab = Vocab(
          id: '1',
          word: '사과',
          meaning: 'Quả táo',
          categoryId: 'cat1',
          createdAt: DateTime.now(),
          familiarity: 0,
        );
        
        final mode = srsService.determineQuizMode(vocab, 0);
        
        expect(mode, QuizMode.flashcard);
      });

      test('learning vocab should use mcq', () {
        final vocab = Vocab(
          id: '1',
          word: '사과',
          meaning: 'Quả táo',
          categoryId: 'cat1',
          createdAt: DateTime.now(),
          familiarity: 1,
        );
        
        final mode = srsService.determineQuizMode(vocab, 0);
        
        expect(mode, QuizMode.mcq);
      });

      test('review vocab with no attempts should use typing', () {
        final vocab = Vocab(
          id: '1',
          word: '사과',
          meaning: 'Quả táo',
          categoryId: 'cat1',
          createdAt: DateTime.now(),
          familiarity: 2,
        );
        
        final mode = srsService.determineQuizMode(vocab, 0);
        
        expect(mode, QuizMode.typing);
      });

      test('review vocab with failed attempts should use flashcard', () {
        final vocab = Vocab(
          id: '1',
          word: '사과',
          meaning: 'Quả táo',
          categoryId: 'cat1',
          createdAt: DateTime.now(),
          familiarity: 2,
        );
        
        // 2 failed attempts should fallback to flashcard
        final mode = srsService.determineQuizMode(vocab, 2);
        
        expect(mode, QuizMode.flashcard);
      });

      test('mastered vocab should use reverse typing', () {
        final vocab = Vocab(
          id: '1',
          word: '사과',
          meaning: 'Quả táo',
          categoryId: 'cat1',
          createdAt: DateTime.now(),
          familiarity: 4,
        );
        
        final mode = srsService.determineQuizMode(vocab, 0);
        
        expect(mode, QuizMode.reverseTyping);
      });

      test('multiple failed attempts should fallback to flashcard', () {
        final vocab = Vocab(
          id: '1',
          word: '사과',
          meaning: 'Quả táo',
          categoryId: 'cat1',
          createdAt: DateTime.now(),
          familiarity: 4,
        );
        
        final mode = srsService.determineQuizMode(vocab, 2);
        
        expect(mode, QuizMode.flashcard);
      });
    });

    group('getDueVocabs', () {
      test('should return vocabs with past nextReview', () {
        final now = DateTime.now();
        final vocabs = [
          Vocab(
            id: '1',
            word: '사과',
            meaning: 'Quả táo',
            categoryId: 'cat1',
            createdAt: now,
            nextReview: now.subtract(const Duration(hours: 1)),
          ),
          Vocab(
            id: '2',
            word: '바나나',
            meaning: 'Quả chuối',
            categoryId: 'cat1',
            createdAt: now,
            nextReview: now.add(const Duration(hours: 1)),
          ),
          Vocab(
            id: '3',
            word: '딸기',
            meaning: 'Quả dâu',
            categoryId: 'cat1',
            createdAt: now,
            // nextReview is null (new vocab)
          ),
        ];
        
        final due = srsService.getDueVocabs(vocabs);
        
        expect(due.length, 2);
        expect(due.map((v) => v.id).contains('1'), true);
        expect(due.map((v) => v.id).contains('3'), true);
        expect(due.map((v) => v.id).contains('2'), false);
      });

      test('should sort by familiarity then nextReview', () {
        final now = DateTime.now();
        final vocabs = [
          Vocab(
            id: '1',
            word: '사과',
            meaning: 'Quả táo',
            categoryId: 'cat1',
            createdAt: now,
            familiarity: 2,
            nextReview: now.subtract(const Duration(hours: 1)),
          ),
          Vocab(
            id: '2',
            word: '바나나',
            meaning: 'Quả chuối',
            categoryId: 'cat1',
            createdAt: now,
            familiarity: 0,
            nextReview: now.subtract(const Duration(hours: 2)),
          ),
          Vocab(
            id: '3',
            word: '딸기',
            meaning: 'Quả dâu',
            categoryId: 'cat1',
            createdAt: now,
            familiarity: 2,
            nextReview: now.subtract(const Duration(hours: 3)),
          ),
        ];
        
        final due = srsService.getDueVocabs(vocabs);
        
        // Should be sorted: familiarity 0 first, then by nextReview
        expect(due[0].id, '2'); // familiarity 0
        expect(due[1].id, '3'); // familiarity 2, earlier nextReview
        expect(due[2].id, '1'); // familiarity 2, later nextReview
      });

      test('should respect limit', () {
        final now = DateTime.now();
        final vocabs = List.generate(30, (i) => Vocab(
          id: '$i',
          word: 'word$i',
          meaning: 'meaning$i',
          categoryId: 'cat1',
          createdAt: now,
        ));
        
        final due = srsService.getDueVocabs(vocabs, limit: 10);
        
        expect(due.length, 10);
      });
    });

    group('calculateAccuracy', () {
      test('should calculate correct percentage', () {
        expect(srsService.calculateAccuracy(8, 10), 0.8);
        expect(srsService.calculateAccuracy(5, 10), 0.5);
        expect(srsService.calculateAccuracy(0, 10), 0.0);
      });

      test('should handle zero total', () {
        expect(srsService.calculateAccuracy(0, 0), 0.0);
      });

      test('should round to 2 decimal places', () {
        expect(srsService.calculateAccuracy(1, 3), 0.33);
      });
    });
  });
}
