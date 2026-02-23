import 'package:mocktail/mocktail.dart';
import 'package:korean_vocab/models/category.dart';
import 'package:korean_vocab/repositories/category_repository.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

class FakeCategory extends Fake implements Category {}

void registerCategoryFallbacks() {
  registerFallbackValue(FakeCategory());
}
