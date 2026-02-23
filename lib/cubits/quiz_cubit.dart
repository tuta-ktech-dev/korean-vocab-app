import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../core/services/srs_service.dart';
import '../models/quiz.dart';
import '../models/vocab.dart';
import '../repositories/vocab_repository.dart';

part 'quiz_state.dart';

class QuizCubit extends Cubit<QuizState> {
  final VocabRepository _vocabRepository;
  final SRSService _srsService = SRSService();

  QuizSession? _currentSession;
  List<Vocab> _allVocabs = [];
  Map<String, Vocab> _vocabMap = {};

  QuizCubit(this._vocabRepository) : super(QuizInitial());

  /// Bắt đầu session ÔN TẬP (chỉ từ đã học và đến hạn)
  Future<void> startSession({String? categoryId, int limit = 10}) async {
    if (limit < 5) limit = 5;
    if (limit > 20) limit = 20;

    emit(QuizLoading());

    try {
      if (categoryId != null) {
        _allVocabs = await _vocabRepository.getVocabsByCategory(categoryId);
      } else {
        _allVocabs = await _vocabRepository.getAllVocabs();
      }

      // Chỉ lấy từ đã học và đến hạn
      final dueVocabs = _srsService.getDueVocabs(_allVocabs, limit: limit);

      if (dueVocabs.isEmpty) {
        emit(
          const QuizNoVocabs(
            'Không có từ nào cần ôn tập!\nHãy học từ mới trước.',
          ),
        );
        return;
      }

      _vocabMap = {for (var v in _allVocabs) v.id: v};

      _currentSession = QuizSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startedAt: DateTime.now(),
        vocabIds: dueVocabs.map((v) => v.id).toList(),
      );

      _emitCurrentQuestion();
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }

  /// Bắt đầu session HỌC TỪ MỚI (từ chưa từng học)
  Future<void> startLearnSession({String? categoryId, int limit = 10}) async {
    if (limit < 1) limit = 1;
    if (limit > 20) limit = 20;

    emit(QuizLoading());

    try {
      if (categoryId != null) {
        _allVocabs = await _vocabRepository.getVocabsByCategory(categoryId);
      } else {
        _allVocabs = await _vocabRepository.getAllVocabs();
      }

      // Chỉ lấy từ chưa học bao giờ
      final newVocabs = _srsService.getNewVocabs(_allVocabs, limit: limit);

      if (newVocabs.isEmpty) {
        emit(
          const QuizNoVocabs(
            'Bạn đã học hết tất cả từ vựng!\nHãy ôn tập để không quên nhé.',
          ),
        );
        return;
      }

      _vocabMap = {for (var v in _allVocabs) v.id: v};

      _currentSession = QuizSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startedAt: DateTime.now(),
        vocabIds: newVocabs.map((v) => v.id).toList(),
        isLearnMode: true,
      );

      _emitCurrentQuestion();
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }

  /// Xử lý câu trả lờ
  Future<void> submitAnswer(QuizResult result) async {
    if (_currentSession == null || state is! QuizQuestion) return;

    try {
      final vocabId = _currentSession!.currentVocabId;
      final vocab = _vocabMap[vocabId]!;

      // Cập nhật session
      _currentSession!.vocabAttempts[vocabId] =
          (_currentSession!.vocabAttempts[vocabId] ?? 0) + 1;

      switch (result) {
        case QuizResult.correct:
          _currentSession!.correctCount++;
          break;
        case QuizResult.incorrect:
          _currentSession!.incorrectCount++;
          break;
        case QuizResult.skip:
          _currentSession!.skippedCount++;
          break;
        case QuizResult.hint:
          break;
      }

      // Tính next review và cập nhật vocab
      final nextReview = _srsService.calculateNextReview(vocab, result);

      final updatedVocab = vocab.copyWith(
        nextReview: nextReview,
        totalReviews: vocab.totalReviews + 1,
        correctCount: result == QuizResult.correct
            ? vocab.correctCount + 1
            : vocab.correctCount,
        accuracy: _srsService.calculateAccuracy(
          result == QuizResult.correct
              ? vocab.correctCount + 1
              : vocab.correctCount,
          vocab.totalReviews + 1,
        ),
        lastReviewed: DateTime.now(),
        familiarity: _calculateFamiliarity(vocab, result),
        streak: _calculateStreak(vocab, result),
      );

      // Lưu vào DB
      await _vocabRepository.updateVocab(updatedVocab);
      _vocabMap[vocabId] = updatedVocab;

      // Hiển thị feedback
      emit(
        QuizFeedback(
          vocab: updatedVocab,
          result: result,
          nextReview: nextReview,
        ),
      );
    } catch (e, stackTrace) {
      print('Error in submitAnswer: $e');
      print('Stack trace: $stackTrace');
      emit(QuizError('Lỗi: $e'));
    }
  }

  /// Chuyển sang câu tiếp theo
  void nextQuestion() {
    if (_currentSession == null) return;

    _currentSession!.currentIndex++;

    if (_currentSession!.isComplete) {
      emit(QuizComplete(_currentSession!));
    } else {
      _emitCurrentQuestion();
    }
  }

  /// Tính familiarity mới
  int _calculateFamiliarity(Vocab vocab, QuizResult result) {
    switch (result) {
      case QuizResult.correct:
        if (vocab.streak >= 2 && vocab.familiarity < 5) {
          return vocab.familiarity + 1;
        }
        return vocab.familiarity;
      case QuizResult.incorrect:
        return (vocab.familiarity - 1).clamp(0, 5);
      case QuizResult.hint:
      case QuizResult.skip:
        return vocab.familiarity;
    }
  }

  /// Tính streak mới
  int _calculateStreak(Vocab vocab, QuizResult result) {
    switch (result) {
      case QuizResult.correct:
        return vocab.streak + 1;
      case QuizResult.incorrect:
        return 0;
      case QuizResult.hint:
      case QuizResult.skip:
        return vocab.streak;
    }
  }

  /// Emit state cho câu hỏi hiện tại
  void _emitCurrentQuestion() {
    if (_currentSession == null) return;

    final vocabId = _currentSession!.currentVocabId;
    final vocab = _vocabMap[vocabId]!;
    final attempts = _currentSession!.vocabAttempts[vocabId] ?? 0;

    // Learn mode: luôn flashcard để giới thiệu từ mới
    // Review mode: xác định mode dựa trên familiarity
    final mode = _currentSession!.isLearnMode
        ? QuizMode.flashcard
        : _srsService.determineQuizMode(vocab, attempts);

    // Tạo options cho MCQ nếu cần
    List<String>? options;
    if (mode == QuizMode.mcq) {
      options = _generateMCQOptions(vocab);
    }

    emit(
      QuizQuestion(
        vocab: vocab,
        mode: mode,
        session: _currentSession!,
        options: options,
        progress: QuizProgress(
          current: _currentSession!.currentIndex + 1,
          total: _currentSession!.vocabIds.length,
        ),
      ),
    );
  }

  /// Tạo đáp án nhiễu cho MCQ
  List<String> _generateMCQOptions(Vocab correctVocab) {
    final options = [correctVocab.meaning];

    // Lấy ngẫu nhiên 3 nghĩa khác
    final otherMeanings =
        _allVocabs
            .where((v) => v.id != correctVocab.id)
            .map((v) => v.meaning)
            .toList()
          ..shuffle();

    options.addAll(otherMeanings.take(3));
    options.shuffle();

    return options;
  }

  void reset() {
    _currentSession = null;
    emit(QuizInitial());
  }
}

class QuizProgress {
  final int current;
  final int total;

  QuizProgress({required this.current, required this.total});
}
