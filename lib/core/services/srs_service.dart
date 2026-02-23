import '../../models/quiz.dart';
import '../../models/vocab.dart';

class SRSService {
  // Intervals theo familiarity (ngày)
  static const List<Duration> _intervals = [
    Duration(minutes: 10), // 0: New - 10 phút
    Duration(days: 1), // 1: Learning - 1 ngày
    Duration(days: 3), // 2: Review - 3 ngày
    Duration(days: 7), // 3: Mastered cấp 1 - 1 tuần
    Duration(days: 14), // 4: Mastered cấp 2 - 2 tuần
    Duration(days: 30), // 5: Mastered cấp 3 - 1 tháng
  ];

  /// Tính next review date dựa trên familiarity và streak
  DateTime calculateNextReview(Vocab vocab, QuizResult result) {
    final now = DateTime.now();

    switch (result) {
      case QuizResult.correct:
        return _handleCorrect(vocab, now);
      case QuizResult.incorrect:
        return _handleIncorrect(vocab, now);
      case QuizResult.hint:
        return _handleHint(vocab, now);
      case QuizResult.skip:
        return _handleSkip(vocab, now);
    }
  }

  DateTime _handleCorrect(Vocab vocab, DateTime now) {
    // Tăng streak và familiarity
    final newStreak = vocab.streak + 1;
    var newFamiliarity = vocab.familiarity;

    // Tăng familiarity sau mỗi 2 lần đúng liên tiếp
    if (newStreak >= 2 && vocab.familiarity < 5) {
      newFamiliarity = vocab.familiarity + 1;
    }

    // Tính interval với streak multiplier
    final baseInterval = _intervals[newFamiliarity.clamp(0, 5)];
    final multiplier = 1 + (newStreak * 0.3); // Mỗi streak tăng 30%
    final adjustedInterval = Duration(
      minutes: (baseInterval.inMinutes * multiplier).round(),
    );

    return now.add(adjustedInterval);
  }

  DateTime _handleIncorrect(Vocab vocab, DateTime now) {
    // Reset streak, giảm familiarity
    var newFamiliarity = vocab.familiarity - 1;
    if (newFamiliarity < 0) newFamiliarity = 0;

    // Ôn lại sau 10 phút
    return now.add(const Duration(minutes: 10));
  }

  DateTime _handleHint(Vocab vocab, DateTime now) {
    // Coi như "gần đúng", không tăng streak, giữ nguyên familiarity
    // Ôn lại sau 1 giờ
    return now.add(const Duration(hours: 1));
  }

  DateTime _handleSkip(Vocab vocab, DateTime now) {
    // Bỏ qua, giữ nguyên mọi thứ, hỏi lại sau 30 phút
    return now.add(const Duration(minutes: 30));
  }

  /// Xác định quiz mode dựa trên familiarity và attempts
  QuizMode determineQuizMode(Vocab vocab, int attempts) {
    // Nếu sai nhiều lần, dễ xuống flashcard
    if (attempts >= 2) {
      return QuizMode.flashcard;
    }

    // Theo familiarity
    switch (vocab.familiarity) {
      case 0: // New
        return QuizMode.flashcard;
      case 1: // Learning
        return QuizMode.mcq;
      case 2: // Review
        return attempts > 0 ? QuizMode.mcq : QuizMode.typing;
      case 3: // Mastered
      case 4:
      case 5:
        return attempts > 0 ? QuizMode.typing : QuizMode.reverseTyping;
      default:
        return QuizMode.flashcard;
    }
  }

  /// Lấy danh sách từ cần ôn tập hôm nay (chỉ từ đã học)
  List<Vocab> getDueVocabs(List<Vocab> allVocabs, {int limit = 20}) {
    final now = DateTime.now();

    final dueVocabs = allVocabs.where((v) {
      // Bỏ qua từ chưa học bao giờ (totalReviews == 0)
      if (v.totalReviews == 0) return false;
      // Lấy từ đã học và đến hạn ôn
      return v.nextReview == null || v.nextReview!.isBefore(now);
    }).toList();

    // Sắp xếp: ưu tiên familiarity thấp và quá hạn lâu nhất
    dueVocabs.sort((a, b) {
      if (a.familiarity != b.familiarity) {
        return a.familiarity.compareTo(b.familiarity);
      }
      return (a.nextReview ?? DateTime(2000)).compareTo(
        b.nextReview ?? DateTime(2000),
      );
    });

    return dueVocabs.take(limit).toList();
  }

  /// Lấy danh sách từ chưa học (để giới thiệu lần đầu)
  List<Vocab> getNewVocabs(List<Vocab> allVocabs, {int limit = 10}) {
    return allVocabs.where((v) => v.totalReviews == 0).take(limit).toList();
  }

  /// Tính accuracy mới
  double calculateAccuracy(int correct, int total) {
    if (total == 0) return 0.0;
    return (correct / total * 100).roundToDouble() / 100;
  }
}
