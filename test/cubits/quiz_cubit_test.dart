import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:korean_vocab/cubits/quiz_cubit.dart';
import 'package:korean_vocab/models/vocab.dart';
import 'package:korean_vocab/models/quiz.dart';

import 'mock_vocab_repository.dart';

void main() {
  late MockVocabRepository repository;
  late QuizCubit cubit;

  final now = DateTime.now();

  final reviewVocabs = [
    Vocab(
      id: '1',
      word: '가방',
      meaning: 'Cặp xách',
      categoryId: 'c1',
      createdAt: now,
      totalReviews: 5,
      familiarity: 1,
      nextReview: now.subtract(const Duration(days: 1)),
    ),
    Vocab(
      id: '2',
      word: '모자',
      meaning: 'Mũ',
      categoryId: 'c1',
      createdAt: now,
      totalReviews: 3,
      familiarity: 2,
      nextReview: now.subtract(const Duration(hours: 1)),
    ),
    Vocab(
      id: '3',
      word: '신발',
      meaning: 'Giày',
      categoryId: 'c1',
      createdAt: now,
      totalReviews: 10,
      familiarity: 4,
      nextReview: now.add(const Duration(days: 3)),
    ),
  ];

  final learnVocabs = [
    Vocab(
      id: '1',
      word: '책상',
      meaning: 'Cái bàn',
      categoryId: 'c2',
      createdAt: now,
      totalReviews: 0,
      familiarity: 0,
    ),
    Vocab(
      id: '2',
      word: '의자',
      meaning: 'Cái ghế',
      categoryId: 'c2',
      createdAt: now,
      totalReviews: 0,
      familiarity: 0,
    ),
    Vocab(
      id: '3',
      word: '침대',
      meaning: 'Cái giường',
      categoryId: 'c2',
      createdAt: now,
      totalReviews: 5,
      familiarity: 2,
    ),
  ];

  setUpAll(() {
    registerFallbacks();
  });

  setUp(() {
    repository = MockVocabRepository();
    cubit = QuizCubit(repository);
  });

  tearDown(() {
    cubit.close();
  });

  group('QuizCubit', () {
    test('initial state is QuizInitial', () {
      expect(cubit.state, isA<QuizInitial>());
    });

    group('startSession (Review Mode)', () {
      blocTest<QuizCubit, QuizState>(
        'emits [QuizLoading, QuizNoVocabs] when no due vocabs exist',
        build: () {
          when(
            () => repository.getAllVocabs(),
          ).thenAnswer((_) async => [reviewVocabs[2]]);
          return cubit;
        },
        act: (cubit) => cubit.startSession(limit: 5),
        expect: () => [isA<QuizLoading>(), isA<QuizNoVocabs>()],
      );

      blocTest<QuizCubit, QuizState>(
        'emits [QuizLoading, QuizQuestion] with due vocabs',
        build: () {
          when(
            () => repository.getAllVocabs(),
          ).thenAnswer((_) async => reviewVocabs);
          return cubit;
        },
        act: (cubit) => cubit.startSession(limit: 5),
        expect: () => [
          isA<QuizLoading>(),
          isA<QuizQuestion>()
              .having((s) => s.vocab.id, 'first vocab id', '1')
              .having((s) => s.progress.current, 'progress current', 1)
              .having((s) => s.progress.total, 'progress total', 2)
              .having((s) => s.mode, 'mode', isNotNull),
        ],
      );
    });

    group('startLearnSession (Learn Mode)', () {
      blocTest<QuizCubit, QuizState>(
        'emits [QuizLoading, QuizNoVocabs] when no unstudied vocabs exist',
        build: () {
          when(
            () => repository.getAllVocabs(),
          ).thenAnswer((_) async => [learnVocabs[2]]);
          return cubit;
        },
        act: (cubit) => cubit.startLearnSession(limit: 5),
        expect: () => [isA<QuizLoading>(), isA<QuizNoVocabs>()],
      );

      blocTest<QuizCubit, QuizState>(
        'emits [QuizLoading, QuizQuestion] with unstudied vocabs',
        build: () {
          when(
            () => repository.getAllVocabs(),
          ).thenAnswer((_) async => learnVocabs);
          return cubit;
        },
        act: (cubit) => cubit.startLearnSession(limit: 5),
        expect: () => [
          isA<QuizLoading>(),
          isA<QuizQuestion>().having((s) => s.vocab.id, 'first vocab id', '1'),
        ],
      );
    });

    group('submitAnswer', () {
      blocTest<QuizCubit, QuizState>(
        'submits answer and emits QuizFeedback',
        build: () {
          when(
            () => repository.getAllVocabs(),
          ).thenAnswer((_) async => [learnVocabs[0]]);
          when(() => repository.updateVocab(any())).thenAnswer((_) async => 1);
          return cubit;
        },
        act: (cubit) async {
          await cubit.startLearnSession(limit: 5);
          await cubit.submitAnswer(QuizResult.correct);
        },
        skip: 2, // Skip Loading and Question
        expect: () => [
          isA<QuizFeedback>().having(
            (s) => s.result,
            'result',
            QuizResult.correct,
          ),
        ],
      );

      blocTest<QuizCubit, QuizState>(
        'nextQuestion after feedback moves to next or completes',
        build: () {
          // One vocab only -> will complete
          when(
            () => repository.getAllVocabs(),
          ).thenAnswer((_) async => [learnVocabs[0]]);
          when(() => repository.updateVocab(any())).thenAnswer((_) async => 1);
          return cubit;
        },
        act: (cubit) async {
          await cubit.startLearnSession(limit: 5);
          await cubit.submitAnswer(QuizResult.correct);
          cubit.nextQuestion();
        },
        skip: 3, // skip Loading, Question, Feedback
        expect: () => [
          isA<QuizComplete>().having(
            (s) => s.session.correctCount,
            'correct stats',
            1,
          ),
        ],
      );
    });
  });
}
