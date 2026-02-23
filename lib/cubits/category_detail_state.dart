part of 'category_detail_cubit.dart';

abstract class CategoryDetailState extends Equatable {
  const CategoryDetailState();

  @override
  List<Object?> get props => [];
}

class CategoryDetailInitial extends CategoryDetailState {}

class CategoryDetailLoading extends CategoryDetailState {}

class CategoryDetailLoaded extends CategoryDetailState {
  final List<Vocab> vocabs;

  const CategoryDetailLoaded(this.vocabs);

  @override
  List<Object?> get props => [vocabs];
}

class CategoryDetailError extends CategoryDetailState {
  final String message;

  const CategoryDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
