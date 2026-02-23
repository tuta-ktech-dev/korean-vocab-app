import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:korean_vocab/cubits/study_cubit.dart';
import 'package:korean_vocab/models/vocab.dart';

import 'mock_vocab_repository.dart';

void main() {
  late MockVocabRepository repository;
  late StudyCubit cubit;

  final mockVocabsCat1 = [
    Vocab(
      id: '1',
      word: '사과',
      meaning: 'Quả táo',
      categoryId: 'cat1',
      createdAt: DateTime.now(),
    ),
  ];

  final mockVocabsAll = [
    ...mockVocabsCat1,
    Vocab(
      id: '2',
      word: '컴퓨터',
      meaning: 'Máy tính',
      categoryId: 'cat2',
      createdAt: DateTime.now(),
    ),
  ];

  setUp(() {
    repository = MockVocabRepository();
    cubit = StudyCubit(repository);
  });

  tearDown(() {
    cubit.close();
  });

  group('StudyCubit', () {
    test('initial state is StudyInitial', () {
      expect(cubit.state, isA<StudyInitial>());
    });

    blocTest<StudyCubit, StudyState>(
      'loadVocabs(null) emits Loading and Loaded with all vocabs',
      build: () {
        when(
          () => repository.getAllVocabs(),
        ).thenAnswer((_) async => mockVocabsAll);
        return cubit;
      },
      act: (cubit) => cubit.loadVocabs(),
      expect: () => [
        isA<StudyLoading>(),
        isA<StudyLoaded>().having((s) => s.vocabs, 'vocabs', mockVocabsAll),
      ],
      verify: (_) {
        verify(() => repository.getAllVocabs()).called(1);
        verifyNever(() => repository.getVocabsByCategory(any()));
      },
    );

    blocTest<StudyCubit, StudyState>(
      'loadVocabs(categoryId) emits Loading and Loaded with category vocabs',
      build: () {
        when(
          () => repository.getVocabsByCategory('cat1'),
        ).thenAnswer((_) async => mockVocabsCat1);
        return cubit;
      },
      act: (cubit) => cubit.loadVocabs(categoryId: 'cat1'),
      expect: () => [
        isA<StudyLoading>(),
        isA<StudyLoaded>().having((s) => s.vocabs, 'vocabs', mockVocabsCat1),
      ],
      verify: (_) {
        verify(() => repository.getVocabsByCategory('cat1')).called(1);
        verifyNever(() => repository.getAllVocabs());
      },
    );

    blocTest<StudyCubit, StudyState>(
      'loadVocabs emits Error when repository throws',
      build: () {
        when(() => repository.getAllVocabs()).thenThrow(Exception('DB Error'));
        return cubit;
      },
      act: (cubit) => cubit.loadVocabs(),
      expect: () => [
        isA<StudyLoading>(),
        isA<StudyError>().having(
          (s) => s.message,
          'message',
          contains('DB Error'),
        ),
      ],
    );
  });
}
