import 'package:mocktail/mocktail.dart';
import 'package:korean_vocab/models/vocab.dart';
import 'package:korean_vocab/repositories/vocab_repository.dart';

class MockVocabRepository extends Mock implements VocabRepository {}

class FakeVocab extends Fake implements Vocab {}

void registerFallbacks() {
  registerFallbackValue(FakeVocab());
}
