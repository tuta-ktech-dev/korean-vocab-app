part of 'vocab_cubit.dart';

abstract class VocabState extends Equatable {
  const VocabState();

  @override
  List<Object?> get props => [];
}

class VocabInitial extends VocabState {}

class VocabLoading extends VocabState {}

class VocabLoaded extends VocabState {
  final List<Vocab> vocabs;

  const VocabLoaded(this.vocabs);

  @override
  List<Object?> get props => [vocabs];
}

class VocabError extends VocabState {
  final String message;

  const VocabError(this.message);

  @override
  List<Object?> get props => [message];
}
