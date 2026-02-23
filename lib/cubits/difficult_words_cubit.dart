import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/vocab.dart';
import '../repositories/vocab_repository.dart';

part 'difficult_words_state.dart';

/// Cubit dành riêng cho DifficultWordsScreen.
/// Load tất cả vocab và lọc ra những từ khó (accuracy thấp).
class DifficultWordsCubit extends Cubit<DifficultWordsState> {
  final VocabRepository _repository;

  DifficultWordsCubit(this._repository) : super(DifficultWordsInitial());

  Future<void> loadDifficultWords() async {
    emit(DifficultWordsLoading());
    try {
      final allVocabs = await _repository.getAllVocabs();
      // Lọc từ đã học và accuracy < 70%
      final difficult =
          allVocabs
              .where((v) => v.totalReviews > 0 && v.accuracy < 0.7)
              .toList()
            ..sort((a, b) => a.accuracy.compareTo(b.accuracy));
      emit(DifficultWordsLoaded(difficult));
    } catch (e) {
      emit(DifficultWordsError(e.toString()));
    }
  }
}
