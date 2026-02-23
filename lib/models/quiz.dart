enum QuizMode {
  flashcard, // Chỉ xem, tự đánh giá
  mcq, // Multiple choice - chọn 1 trong 4
  typing, // Gõ đáp án
  reverseTyping, // Xem nghĩa, gõ từ Hàn
}

enum QuizResult {
  correct, // Đúng
  incorrect, // Sai
  hint, // Xem hint
  skip, // Bỏ qua
}

class QuizSession {
  final String id;
  final DateTime startedAt;
  final List<String> vocabIds;
  final bool isLearnMode; // true = học từ mới, false = ôn tập
  int currentIndex;
  int correctCount;
  int incorrectCount;
  int skippedCount;
  Map<String, QuizMode> vocabModes;
  Map<String, int> vocabAttempts;

  QuizSession({
    required this.id,
    required this.startedAt,
    required this.vocabIds,
    this.isLearnMode = false,
    this.currentIndex = 0,
    this.correctCount = 0,
    this.incorrectCount = 0,
    this.skippedCount = 0,
    Map<String, QuizMode>? vocabModes,
    Map<String, int>? vocabAttempts,
  }) : vocabModes = vocabModes ?? {},
       vocabAttempts = vocabAttempts ?? {};

  double get accuracy => correctCount + incorrectCount > 0
      ? correctCount / (correctCount + incorrectCount)
      : 0;

  bool get isComplete => currentIndex >= vocabIds.length;

  String get currentVocabId => isComplete ? '' : vocabIds[currentIndex];
}
