import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:korean_vocab/cubits/statistics_cubit.dart';
import 'package:korean_vocab/models/vocab.dart';

import 'mock_vocab_repository.dart';

void main() {
  late MockVocabRepository repository;
  late StatisticsCubit cubit;

  final now = DateTime.now();

  final mockVocabs = [
    // 1. Mastered word (familiarity >= 3)
    Vocab(
      id: '1',
      word: '사과',
      meaning: 'Quả táo',
      categoryId: 'cat1',
      createdAt: now,
      totalReviews: 10,
      familiarity: 3,
      accuracy: 0.9,
    ),
    // 2. Reviewing word (familiarity == 2)
    Vocab(
      id: '2',
      word: '바나나',
      meaning: 'Quả chuối',
      categoryId: 'cat1',
      createdAt: now,
      totalReviews: 5,
      familiarity: 2,
      accuracy: 0.8,
    ),
    // 3. New word (familiarity == 0 but reviewed > 0)
    Vocab(
      id: '3',
      word: '공부하다',
      meaning: 'Học',
      categoryId: 'cat1',
      createdAt: now,
      totalReviews: 1,
      familiarity: 0,
      accuracy: 0.0,
      nextReview: now.subtract(const Duration(minutes: 10)), // Due today
    ),
    // 4. Not started (totalReviews == 0)
    Vocab(
      id: '4',
      word: '학교',
      meaning: 'Trường học',
      categoryId: 'cat1',
      createdAt: now,
      totalReviews: 0,
      familiarity: 0,
      accuracy: 0.0,
    ),
  ];

  setUp(() {
    repository = MockVocabRepository();
    cubit = StatisticsCubit(repository);
  });

  tearDown(() {
    cubit.close();
  });

  group('StatisticsCubit', () {
    test('initial state is StatisticsInitial', () {
      expect(cubit.state, isA<StatisticsInitial>());
    });

    blocTest<StatisticsCubit, StatisticsState>(
      'loadStatistics emits Loading and Loaded with calculated stats',
      build: () {
        when(
          () => repository.getAllVocabs(),
        ).thenAnswer((_) async => mockVocabs);
        return cubit;
      },
      act: (cubit) => cubit.loadStatistics(),
      expect: () => [
        isA<StatisticsLoading>(),
        isA<StatisticsLoaded>()
            .having((s) => s.vocabs, 'vocabs', mockVocabs)
            .having((s) => s.stats['total'], 'total', 4)
            .having((s) => s.stats['mastered'], 'mastered', 1)
            .having((s) => s.stats['reviewing'], 'reviewing', 1)
            .having((s) => s.stats['new'], 'new', 1)
            .having((s) => s.stats['notStarted'], 'notStarted', 1)
            .having((s) => s.stats['totalReviews'], 'totalReviews', 16)
            // Accuracy: 0.9 + 0.8 + 0.0 = 1.7.  1.7 / 4 * 100 = 42
            .having((s) => s.stats['averageAccuracy'], 'averageAccuracy', 42)
            .having((s) => s.stats['dueToday'], 'dueToday', 1),
      ],
      verify: (_) {
        verify(() => repository.getAllVocabs()).called(1);
      },
    );

    blocTest<StatisticsCubit, StatisticsState>(
      'loadStatistics emits Loading and Error when repository throws',
      build: () {
        when(() => repository.getAllVocabs()).thenThrow(Exception('DB Error'));
        return cubit;
      },
      act: (cubit) => cubit.loadStatistics(),
      expect: () => [
        isA<StatisticsLoading>(),
        isA<StatisticsError>().having(
          (s) => s.message,
          'message',
          contains('DB Error'),
        ),
      ],
    );
  });
}
