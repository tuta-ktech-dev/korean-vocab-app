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
    final total = vocabs.length;
    final studied = vocabs.where((v) => v.totalReviews > 0).length;
    final mastered = vocabs.where((v) => v.familiarity >= 3).length;
    final learning = vocabs
        .where((v) => v.familiarity > 0 && v.familiarity < 3)
        .length;
    final notStudied = vocabs.where((v) => v.totalReviews == 0).length;

    final totalReviews = vocabs.fold(0, (sum, v) => sum + v.totalReviews);
    final avgAccuracy = studied > 0
        ? vocabs
                  .where((v) => v.totalReviews > 0)
                  .fold(0.0, (sum, v) => sum + v.accuracy) /
              studied
        : 0.0;
    final maxStreak = vocabs.fold(
      0,
      (max, v) => v.streak > max ? v.streak : max,
    );

    return {
      'total': total,
      'studied': studied,
      'mastered': mastered,
      'learning': learning,
      'notStudied': notStudied,
      'totalReviews': totalReviews,
      'avgAccuracy': avgAccuracy,
      'maxStreak': maxStreak,
    };
  }
}
