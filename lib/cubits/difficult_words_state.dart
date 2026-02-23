part of 'difficult_words_cubit.dart';

abstract class DifficultWordsState extends Equatable {
  const DifficultWordsState();

  @override
  List<Object?> get props => [];
}

class DifficultWordsInitial extends DifficultWordsState {}

class DifficultWordsLoading extends DifficultWordsState {}

class DifficultWordsLoaded extends DifficultWordsState {
  final List<Vocab> words;

  const DifficultWordsLoaded(this.words);

  @override
  List<Object?> get props => [words];
}

class DifficultWordsError extends DifficultWordsState {
  final String message;

  const DifficultWordsError(this.message);

  @override
  List<Object?> get props => [message];
}
