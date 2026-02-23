import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/vocab.dart';
import '../repositories/vocab_repository.dart';

part 'study_state.dart';

/// Cubit dành riêng cho StudyScreen.
/// Load vocab để học flashcard (all hoặc theo category).
class StudyCubit extends Cubit<StudyState> {
  final VocabRepository _repository;

  StudyCubit(this._repository) : super(StudyInitial());

  Future<void> loadVocabs({String? categoryId}) async {
    emit(StudyLoading());
    try {
      final vocabs = categoryId != null
          ? await _repository.getVocabsByCategory(categoryId)
          : await _repository.getAllVocabs();
      emit(StudyLoaded(vocabs));
    } catch (e) {
      emit(StudyError(e.toString()));
    }
  }
}
