import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:korean_vocab/cubits/category_cubit.dart';
import 'package:korean_vocab/models/category.dart';

import 'mock_category_repository.dart';

void main() {
  late MockCategoryRepository repository;
  late CategoryCubit cubit;

  final mockCategories = [
    Category(id: '1', name: 'Động vật', nameKorean: '동물'),
    Category(id: '2', name: 'Trái cây', nameKorean: '과일'),
  ];

  setUpAll(() {
    registerCategoryFallbacks();
  });

  setUp(() {
    repository = MockCategoryRepository();
    cubit = CategoryCubit(repository);
  });

  tearDown(() {
    cubit.close();
  });

  group('CategoryCubit', () {
    test('initial state is CategoryInitial', () {
      expect(cubit.state, isA<CategoryInitial>());
    });

    blocTest<CategoryCubit, CategoryState>(
      'loadCategories emits Loading and Loaded on success',
      build: () {
        when(
          () => repository.getAllCategories(),
        ).thenAnswer((_) async => mockCategories);
        return cubit;
      },
      act: (cubit) => cubit.loadCategories(),
      expect: () => [
        isA<CategoryLoading>(),
        isA<CategoryLoaded>().having(
          (s) => s.categories,
          'categories',
          mockCategories,
        ),
      ],
      verify: (_) {
        verify(() => repository.getAllCategories()).called(1);
      },
    );

    blocTest<CategoryCubit, CategoryState>(
      'loadCategories emits Loading and Error when repository throws',
      build: () {
        when(
          () => repository.getAllCategories(),
        ).thenThrow(Exception('DB Error'));
        return cubit;
      },
      act: (cubit) => cubit.loadCategories(),
      expect: () => [
        isA<CategoryLoading>(),
        isA<CategoryError>().having(
          (s) => s.message,
          'message',
          contains('DB Error'),
        ),
      ],
    );

    blocTest<CategoryCubit, CategoryState>(
      'addCategory inserts category and reloads',
      build: () {
        when(() => repository.insertCategory(any())).thenAnswer((_) async => 1);
        when(
          () => repository.getAllCategories(),
        ).thenAnswer((_) async => mockCategories);
        return cubit;
      },
      act: (cubit) => cubit.addCategory('Thực vật', nameKorean: '식물'),
      expect: () => [
        isA<CategoryLoading>(), // Emitted by loadCategories
        isA<CategoryLoaded>(),
      ],
      verify: (_) {
        verify(() => repository.insertCategory(any())).called(1);
        verify(() => repository.getAllCategories()).called(1);
      },
    );

    blocTest<CategoryCubit, CategoryState>(
      'deleteCategory deletes category and reloads',
      build: () {
        when(() => repository.deleteCategory(any())).thenAnswer((_) async => 1);
        when(
          () => repository.getAllCategories(),
        ).thenAnswer((_) async => mockCategories);
        return cubit;
      },
      act: (cubit) => cubit.deleteCategory('1'),
      expect: () => [
        isA<CategoryLoading>(), // Emitted by loadCategories
        isA<CategoryLoaded>(),
      ],
      verify: (_) {
        verify(() => repository.deleteCategory('1')).called(1);
        verify(() => repository.getAllCategories()).called(1);
      },
    );
  });
}
