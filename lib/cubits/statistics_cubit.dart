import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/vocab.dart';
import '../repositories/vocab_repository.dart';

part 'statistics_state.dart';

/// Cubit dành riêng cho StatisticsScreen.
/// Load tất cả vocab và tính toán thống kê.
class StatisticsCubit extends Cubit<StatisticsState> {
  final VocabRepository _repository;

  StatisticsCubit(this._repository) : super(StatisticsInitial());

  Future<void> loadStatistics() async {
    emit(StatisticsLoading());
    try {
      final allVocabs = await _repository.getAllVocabs();
      final stats = _computeStats(allVocabs);
      emit(StatisticsLoaded(vocabs: allVocabs, stats: stats));
    } catch (e) {
      emit(StatisticsError(e.toString()));
    }
  }

  Map<String, dynamic> _computeStats(List<Vocab> vocabs) {
    final now = DateTime.now();

    int notStarted = 0;
    int newCount = 0;
    int learning = 0;
    int reviewing = 0;
    int mastered = 0;
    int totalReviews = 0;
    double totalAccuracy = 0;
    int dueToday = 0;

    for (final vocab in vocabs) {
      if (vocab.totalReviews == 0) {
        notStarted++;
      } else if (vocab.familiarity == 0) {
        newCount++;
      } else if (vocab.familiarity == 1) {
        learning++;
      } else if (vocab.familiarity == 2) {
        reviewing++;
      } else {
        mastered++;
      }

      totalReviews += vocab.totalReviews;
      totalAccuracy += vocab.accuracy;

      if (vocab.nextReview != null &&
          vocab.nextReview!.isBefore(now.add(const Duration(days: 1)))) {
        dueToday++;
      }
    }

    return {
      'total': vocabs.length,
      'notStarted': notStarted,
      'new': newCount,
      'learning': learning,
      'reviewing': reviewing,
      'mastered': mastered,
      'totalReviews': totalReviews,
      'averageAccuracy': vocabs.isNotEmpty
          ? (totalAccuracy / vocabs.length * 100).toInt()
          : 0,
      'dueToday': dueToday,
    };
  }
}
