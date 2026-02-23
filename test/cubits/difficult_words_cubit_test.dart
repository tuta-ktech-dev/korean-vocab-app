import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:korean_vocab/cubits/difficult_words_cubit.dart';
import 'package:korean_vocab/models/vocab.dart';

import 'mock_vocab_repository.dart';

void main() {
  late MockVocabRepository repository;
  late DifficultWordsCubit cubit;

  final now = DateTime.now();

  final mockVocabs = [
    // 1. Difficult word (reviewed > 0, accuracy < 0.7)
    Vocab(
      id: '1',
      word: '어렵다',
      meaning: 'Khó',
      categoryId: 'cat1',
      createdAt: now,
      totalReviews: 5,
      accuracy: 0.4,
    ),
    // 2. Easy word (reviewed > 0, accuracy >= 0.7)
    Vocab(
      id: '2',
      word: '쉽다',
      meaning: 'Dễ',
      categoryId: 'cat1',
      createdAt: now,
      totalReviews: 10,
      accuracy: 0.9,
    ),
    // 3. Unstudied word (reviewed == 0)
    Vocab(
      id: '3',
      word: '새롭다',
      meaning: 'Mới',
      categoryId: 'cat1',
      createdAt: now,
      totalReviews: 0,
      accuracy: 0.0,
    ),
    // 4. Another difficult word but worse accuracy
    Vocab(
      id: '4',
      word: '복잡하다',
      meaning: 'Phức tạp',
      categoryId: 'cat1',
      createdAt: now,
      totalReviews: 8,
      accuracy: 0.2, // Should come before id 1 in sorted results
    ),
  ];

  setUp(() {
    repository = MockVocabRepository();
    cubit = DifficultWordsCubit(repository);
  });

  tearDown(() {
    cubit.close();
  });

  group('DifficultWordsCubit', () {
    test('initial state is DifficultWordsInitial', () {
      expect(cubit.state, isA<DifficultWordsInitial>());
    });

    blocTest<DifficultWordsCubit, DifficultWordsState>(
      'loadDifficultWords emits Loading and Loaded with filtered and sorted words',
      build: () {
        when(
          () => repository.getAllVocabs(),
        ).thenAnswer((_) async => mockVocabs);
        return cubit;
      },
      act: (cubit) => cubit.loadDifficultWords(),
      expect: () => [
        isA<DifficultWordsLoading>(),
        isA<DifficultWordsLoaded>().having(
          (s) => s.words.map((v) => v.id).toList(),
          'sorted difficult word IDs',
          ['4', '1'], // 0.2 accuracy first, then 0.4. ID 2 and 3 omitted.
        ),
      ],
      verify: (_) {
        verify(() => repository.getAllVocabs()).called(1);
      },
    );

    blocTest<DifficultWordsCubit, DifficultWordsState>(
      'loadDifficultWords emits Loading and Error when repository throws',
      build: () {
        when(() => repository.getAllVocabs()).thenThrow(Exception('DB Error'));
        return cubit;
      },
      act: (cubit) => cubit.loadDifficultWords(),
      expect: () => [
        isA<DifficultWordsLoading>(),
        isA<DifficultWordsError>().having(
          (s) => s.message,
          'message',
          contains('DB Error'),
        ),
      ],
    );
  });
}
