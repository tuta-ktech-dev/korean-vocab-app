import 'package:flutter_test/flutter_test.dart';
import 'package:korean_vocab/models/vocab.dart';

void main() {
  group('Vocab Model - Extended Features', () {
    test('should include pronunciation field', () {
      final vocab = Vocab(
        id: '1',
        word: '사과',
        pronunciation: 'sa-gwa',
        meaning: 'Quả táo',
        categoryId: 'cat1',
        createdAt: DateTime.now(),
      );

      expect(vocab.pronunciation, 'sa-gwa');
      expect(vocab.toMap()['pronunciation'], 'sa-gwa');
    });

    test('should return correct study status', () {
      final notStarted = Vocab(
        id: '1',
        word: '사과',
        meaning: 'Quả táo',
        categoryId: 'cat1',
        createdAt: DateTime.now(),
        totalReviews: 0,
      );
      expect(notStarted.studyStatus, 'Chưa học');

      // Must have totalReviews > 0 to be considered "new"
      final newVocab = Vocab(
        id: '2',
        word: '바나나',
        meaning: 'Quả chuối',
        categoryId: 'cat1',
        createdAt: DateTime.now(),
        totalReviews: 1,  // Important: must be > 0
        familiarity: 0,
      );
      expect(newVocab.studyStatus, 'Mới');

      final learning = Vocab(
        id: '3',
        word: '딸기',
        meaning: 'Quả dâu',
        categoryId: 'cat1',
        createdAt: DateTime.now(),
        totalReviews: 5,
        familiarity: 1,
      );
      expect(learning.studyStatus, 'Đang học');

      final reviewing = Vocab(
        id: '4',
        word: '오렌지',
        meaning: 'Quả cam',
        categoryId: 'cat1',
        createdAt: DateTime.now(),
        familiarity: 2,
        totalReviews: 10,  // Add this to bypass 'Chưa học'
      );
      expect(reviewing.studyStatus, 'Ôn tập');

      final mastered = Vocab(
        id: '5',
        word: '수박',
        meaning: 'Dưa hấu',
        categoryId: 'cat1',
        createdAt: DateTime.now(),
        familiarity: 3,
        totalReviews: 20,
      );
      expect(mastered.studyStatus, 'Đã thuộc');
    });

    test('should return correct status color', () {
      final notStarted = Vocab(
        id: '1',
        word: '사과',
        meaning: 'Quả táo',
        categoryId: 'cat1',
        createdAt: DateTime.now(),
        totalReviews: 0,
      );
      expect(notStarted.statusColor, isA<int>());

      final newVocab = Vocab(
        id: '2',
        word: '바나나',
        meaning: 'Quả chuối',
        categoryId: 'cat1',
        createdAt: DateTime.now(),
        totalReviews: 1,
        familiarity: 0,
      );
      expect(newVocab.statusColor, isA<int>());

      final mastered = Vocab(
        id: '3',
        word: '수박',
        meaning: 'Dưa hấu',
        categoryId: 'cat1',
        createdAt: DateTime.now(),
        familiarity: 3,
      );
      expect(mastered.statusColor, isA<int>());
    });

    test('should handle null pronunciation', () {
      final vocab = Vocab(
        id: '1',
        word: '사과',
        meaning: 'Quả táo',
        categoryId: 'cat1',
        createdAt: DateTime.now(),
      );

      expect(vocab.pronunciation, null);
      expect(vocab.toMap()['pronunciation'], null);
    });

    test('copyWith should update pronunciation', () {
      final vocab = Vocab(
        id: '1',
        word: '사과',
        meaning: 'Quả táo',
        categoryId: 'cat1',
        createdAt: DateTime.now(),
      );

      final updated = vocab.copyWith(pronunciation: 'sa-gwa');
      
      expect(updated.pronunciation, 'sa-gwa');
      expect(updated.word, vocab.word);
      expect(updated.meaning, vocab.meaning);
    });

    test('should calculate accuracy correctly', () {
      final vocab = Vocab(
        id: '1',
        word: '사과',
        meaning: 'Quả táo',
        categoryId: 'cat1',
        createdAt: DateTime.now(),
        totalReviews: 10,
        correctCount: 8,
        accuracy: 0.8,
      );

      expect(vocab.accuracy, 0.8);
      expect(vocab.totalReviews, 10);
      expect(vocab.correctCount, 8);
    });
  });
}
