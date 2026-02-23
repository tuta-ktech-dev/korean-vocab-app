part of 'study_cubit.dart';

abstract class StudyState extends Equatable {
  const StudyState();

  @override
  List<Object?> get props => [];
}

class StudyInitial extends StudyState {}

class StudyLoading extends StudyState {}

class StudyLoaded extends StudyState {
  final List<Vocab> vocabs;

  const StudyLoaded(this.vocabs);

  @override
  List<Object?> get props => [vocabs];
}

class StudyError extends StudyState {
  final String message;

  const StudyError(this.message);

  @override
  List<Object?> get props => [message];
}
