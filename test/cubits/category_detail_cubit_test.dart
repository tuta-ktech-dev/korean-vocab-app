import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:korean_vocab/cubits/category_detail_cubit.dart';
import 'package:korean_vocab/models/vocab.dart';

import 'mock_vocab_repository.dart';

void main() {
  late MockVocabRepository repository;
  late CategoryDetailCubit cubit;
  final categoryId = 'test_cat';

  final mockVocabs = [
    Vocab(
      id: '1',
      word: '사과',
      meaning: 'Quả táo',
      categoryId: categoryId,
      createdAt: DateTime.now(),
    ),
  ];

  setUpAll(() {
    registerFallbacks();
  });

  setUp(() {
    repository = MockVocabRepository();
    cubit = CategoryDetailCubit(repository, categoryId: categoryId);
  });

  tearDown(() {
    cubit.close();
  });

  group('CategoryDetailCubit', () {
    test('initial state is CategoryDetailInitial', () {
      expect(cubit.state, isA<CategoryDetailInitial>());
    });

    blocTest<CategoryDetailCubit, CategoryDetailState>(
      'loadVocabs emits [CategoryDetailLoading, CategoryDetailLoaded] when successful',
      build: () {
        when(
          () => repository.getVocabsByCategory(categoryId),
        ).thenAnswer((_) async => mockVocabs);
        return cubit;
      },
      act: (cubit) => cubit.loadVocabs(),
      expect: () => [
        isA<CategoryDetailLoading>(),
        isA<CategoryDetailLoaded>().having(
          (s) => s.vocabs,
          'vocabs',
          mockVocabs,
        ),
      ],
      verify: (_) {
        verify(() => repository.getVocabsByCategory(categoryId)).called(1);
      },
    );

    blocTest<CategoryDetailCubit, CategoryDetailState>(
      'loadVocabs emits [CategoryDetailLoading, CategoryDetailError] when repository throws',
      build: () {
        when(
          () => repository.getVocabsByCategory(categoryId),
        ).thenThrow(Exception('DB Error'));
        return cubit;
      },
      act: (cubit) => cubit.loadVocabs(),
      expect: () => [
        isA<CategoryDetailLoading>(),
        isA<CategoryDetailError>().having(
          (s) => s.message,
          'message',
          contains('DB Error'),
        ),
      ],
    );

    blocTest<CategoryDetailCubit, CategoryDetailState>(
      'addVocab emits updated vocabs when successful (no image)',
      build: () {
        when(() => repository.insertVocab(any())).thenAnswer((_) async => 1);
        when(
          () => repository.getVocabsByCategory(categoryId),
        ).thenAnswer((_) async => mockVocabs);
        return cubit;
      },
      act: (cubit) => cubit.addVocab(word: '테스트', meaning: 'Test'),
      expect: () => [
        isA<CategoryDetailLoading>(), // from loadVocabs
        isA<CategoryDetailLoaded>(),
      ],
      verify: (_) {
        verify(() => repository.insertVocab(any())).called(1);
        verify(() => repository.getVocabsByCategory(categoryId)).called(1);
      },
    );

    blocTest<CategoryDetailCubit, CategoryDetailState>(
      'deleteVocab emits updated vocabs when successful',
      build: () {
        when(() => repository.deleteVocab(any())).thenAnswer((_) async => 1);
        when(
          () => repository.getVocabsByCategory(categoryId),
        ).thenAnswer((_) async => mockVocabs);
        return cubit;
      },
      act: (cubit) => cubit.deleteVocab('1'),
      expect: () => [
        isA<CategoryDetailLoading>(), // from loadVocabs
        isA<CategoryDetailLoaded>(),
      ],
      verify: (_) {
        verify(() => repository.deleteVocab('1')).called(1);
        verify(() => repository.getVocabsByCategory(categoryId)).called(1);
      },
    );

    blocTest<CategoryDetailCubit, CategoryDetailState>(
      'updateVocab emits updated vocabs when successful',
      build: () {
        when(() => repository.updateVocab(any())).thenAnswer((_) async => 1);
        when(
          () => repository.getVocabsByCategory(categoryId),
        ).thenAnswer((_) async => mockVocabs);
        return cubit;
      },
      act: (cubit) => cubit.updateVocab(mockVocabs.first),
      expect: () => [
        isA<CategoryDetailLoading>(), // from loadVocabs
        isA<CategoryDetailLoaded>(),
      ],
      verify: (_) {
        verify(() => repository.updateVocab(any())).called(1);
        verify(() => repository.getVocabsByCategory(categoryId)).called(1);
      },
    );
  });
}
