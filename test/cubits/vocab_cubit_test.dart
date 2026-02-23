import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:korean_vocab/cubits/vocab_cubit.dart';
import 'package:korean_vocab/models/vocab.dart';

import 'mock_vocab_repository.dart';

void main() {
  late MockVocabRepository repository;
  late VocabCubit cubit;

  final mockVocabs = [
    Vocab(
      id: '1',
      word: '사과',
      meaning: 'Quả táo',
      categoryId: 'cat1',
      createdAt: DateTime.now(),
    ),
  ];

  setUpAll(() {
    registerFallbacks();
  });

  setUp(() {
    repository = MockVocabRepository();
    cubit = VocabCubit(repository);
  });

  tearDown(() {
    cubit.close();
  });

  group('VocabCubit', () {
    test('initial state is VocabInitial', () {
      expect(cubit.state, isA<VocabInitial>());
    });

    blocTest<VocabCubit, VocabState>(
      'loadVocabs(null) emits Loading and Loaded with all vocabs',
      build: () {
        when(
          () => repository.getAllVocabs(),
        ).thenAnswer((_) async => mockVocabs);
        return cubit;
      },
      act: (cubit) => cubit.loadVocabs(),
      expect: () => [
        isA<VocabLoading>(),
        isA<VocabLoaded>().having((s) => s.vocabs, 'vocabs', mockVocabs),
      ],
      verify: (_) {
        verify(() => repository.getAllVocabs()).called(1);
        verifyNever(() => repository.getVocabsByCategory(any()));
      },
    );

    blocTest<VocabCubit, VocabState>(
      'loadVocabs(categoryId) emits Loading and Loaded with category vocabs',
      build: () {
        when(
          () => repository.getVocabsByCategory('cat1'),
        ).thenAnswer((_) async => mockVocabs);
        return cubit;
      },
      act: (cubit) => cubit.loadVocabs(categoryId: 'cat1'),
      expect: () => [
        isA<VocabLoading>(),
        isA<VocabLoaded>().having((s) => s.vocabs, 'vocabs', mockVocabs),
      ],
      verify: (_) {
        verify(() => repository.getVocabsByCategory('cat1')).called(1);
        verifyNever(() => repository.getAllVocabs());
      },
    );
  });
}
