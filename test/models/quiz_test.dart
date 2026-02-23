import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:korean_vocab/models/quiz.dart';

// Mock Database
class MockDatabase extends Mock implements Database {}

void main() {
  group('Quiz Model', () {
    test('should create quiz session correctly', () {
      final session = QuizSession(
        id: 'session1',
        startedAt: DateTime.now(),
        vocabIds: ['1', '2', '3'],
      );
      
      expect(session.id, 'session1');
      expect(session.vocabIds.length, 3);
      expect(session.currentIndex, 0);
      expect(session.correctCount, 0);
      expect(session.incorrectCount, 0);
      expect(session.isComplete, false);
    });

    test('should track current vocab correctly', () {
      final session = QuizSession(
        id: 'session1',
        startedAt: DateTime.now(),
        vocabIds: ['1', '2', '3'],
      );
      
      expect(session.currentVocabId, '1');
      
      session.currentIndex = 1;
      expect(session.currentVocabId, '2');
    });

    test('should detect completion', () {
      final session = QuizSession(
        id: 'session1',
        startedAt: DateTime.now(),
        vocabIds: ['1', '2'],
      );
      
      expect(session.isComplete, false);
      
      session.currentIndex = 2;
      expect(session.isComplete, true);
    });

    test('should calculate accuracy correctly', () {
      final session = QuizSession(
        id: 'session1',
        startedAt: DateTime.now(),
        vocabIds: ['1', '2', '3', '4'],
        correctCount: 3,
        incorrectCount: 1,
      );
      
      expect(session.accuracy, 0.75);
    });

    test('should track vocab modes', () {
      final session = QuizSession(
        id: 'session1',
        startedAt: DateTime.now(),
        vocabIds: ['1', '2'],
        vocabModes: {'1': QuizMode.flashcard},
      );
      
      expect(session.vocabModes['1'], QuizMode.flashcard);
    });

    test('should track vocab attempts', () {
      final session = QuizSession(
        id: 'session1',
        startedAt: DateTime.now(),
        vocabIds: ['1', '2'],
        vocabAttempts: {'1': 2, '2': 1},
      );
      
      expect(session.vocabAttempts['1'], 2);
      expect(session.vocabAttempts['2'], 1);
    });
  });

  group('QuizResult', () {
    test('should have all result types', () {
      expect(QuizResult.values.length, 4);
      expect(QuizResult.values.contains(QuizResult.correct), true);
      expect(QuizResult.values.contains(QuizResult.incorrect), true);
      expect(QuizResult.values.contains(QuizResult.hint), true);
      expect(QuizResult.values.contains(QuizResult.skip), true);
    });
  });

  group('QuizMode', () {
    test('should have all quiz modes', () {
      expect(QuizMode.values.length, 4);
      expect(QuizMode.values.contains(QuizMode.flashcard), true);
      expect(QuizMode.values.contains(QuizMode.mcq), true);
      expect(QuizMode.values.contains(QuizMode.typing), true);
      expect(QuizMode.values.contains(QuizMode.reverseTyping), true);
    });
  });
}
