part of 'quiz_cubit.dart';

abstract class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object?> get props => [];
}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class QuizNoVocabs extends QuizState {
  final String message;
  
  const QuizNoVocabs(this.message);
  
  @override
  List<Object?> get props => [message];
}

class QuizQuestion extends QuizState {
  final Vocab vocab;
  final QuizMode mode;
  final QuizSession session;
  final List<String>? options; // Cho MCQ
  final QuizProgress progress;
  
  const QuizQuestion({
    required this.vocab,
    required this.mode,
    required this.session,
    this.options,
    required this.progress,
  });
  
  @override
  List<Object?> get props => [vocab, mode, session, options, progress];
}

class QuizFeedback extends QuizState {
  final Vocab vocab;
  final QuizResult result;
  final DateTime nextReview;
  
  const QuizFeedback({
    required this.vocab,
    required this.result,
    required this.nextReview,
  });
  
  @override
  List<Object?> get props => [vocab, result, nextReview];
}

class QuizComplete extends QuizState {
  final QuizSession session;
  
  const QuizComplete(this.session);
  
  @override
  List<Object?> get props => [session];
}

class QuizError extends QuizState {
  final String message;
  
  const QuizError(this.message);
  
  @override
  List<Object?> get props => [message];
}
