enum QuizMode {
  flashcard,  // Chỉ xem, tự đánh giá
  mcq,        // Multiple choice - chọn 1 trong 4
  typing,     // Gõ đáp án
  reverseTyping, // Xem nghĩa, gõ từ Hàn
}

enum QuizResult {
  correct,    // Đúng
  incorrect,  // Sai
  hint,       // Xem hint
  skip,       // Bỏ qua
}

class QuizSession {
  final String id;
  final DateTime startedAt;
  final List<String> vocabIds;
  int currentIndex;
  int correctCount;
  int incorrectCount;
  int skippedCount;
  Map<String, QuizMode> vocabModes; // Từ nào học bằng mode gì
  Map<String, int> vocabAttempts;    // Số lần thử của mỗi từ
  
  QuizSession({
    required this.id,
    required this.startedAt,
    required this.vocabIds,
    this.currentIndex = 0,
    this.correctCount = 0,
    this.incorrectCount = 0,
    this.skippedCount = 0,
    Map<String, QuizMode>? vocabModes,
    Map<String, int>? vocabAttempts,
  }) : vocabModes = vocabModes ?? {},
       vocabAttempts = vocabAttempts ?? {};

  double get accuracy => 
      correctCount + incorrectCount > 0 
          ? correctCount / (correctCount + incorrectCount) 
          : 0;
  
  bool get isComplete => currentIndex >= vocabIds.length;
  
  String get currentVocabId => 
      isComplete ? '' : vocabIds[currentIndex];
}
