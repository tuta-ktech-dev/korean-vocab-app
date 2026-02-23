class Vocab {
  final String id;
  final String word;
  final String? pronunciation; // Phiên âm (e.g., "sa-gwa" for 사과)
  final String meaning;
  final String? example;
  final String? exampleMeaning;
  final String? note;
  final String categoryId;
  final String? imagePath;
  final DateTime createdAt;
  
  // SRS Fields
  int familiarity;
  int streak;
  DateTime? nextReview;
  int totalReviews;
  int correctCount;
  double accuracy;
  DateTime? lastReviewed;
  int timeSpent;

  Vocab({
    required this.id,
    required this.word,
    this.pronunciation,
    required this.meaning,
    this.example,
    this.exampleMeaning,
    this.note,
    required this.categoryId,
    this.imagePath,
    required this.createdAt,
    this.familiarity = 0,
    this.streak = 0,
    this.nextReview,
    this.totalReviews = 0,
    this.correctCount = 0,
    this.accuracy = 0.0,
    this.lastReviewed,
    this.timeSpent = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'pronunciation': pronunciation,
      'meaning': meaning,
      'example': example,
      'example_meaning': exampleMeaning,
      'note': note,
      'category_id': categoryId,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
      'familiarity': familiarity,
      'streak': streak,
      'next_review': nextReview?.toIso8601String(),
      'total_reviews': totalReviews,
      'correct_count': correctCount,
      'accuracy': accuracy,
      'last_reviewed': lastReviewed?.toIso8601String(),
      'time_spent': timeSpent,
    };
  }

  factory Vocab.fromMap(Map<String, dynamic> map) {
    return Vocab(
      id: map['id'] as String,
      word: map['word'] as String,
      pronunciation: map['pronunciation'] as String?,
      meaning: map['meaning'] as String,
      example: map['example'] as String?,
      exampleMeaning: map['example_meaning'] as String?,
      note: map['note'] as String?,
      categoryId: map['category_id'] as String,
      imagePath: map['image_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      familiarity: map['familiarity'] as int? ?? 0,
      streak: map['streak'] as int? ?? 0,
      nextReview: map['next_review'] != null 
          ? DateTime.parse(map['next_review'] as String) 
          : null,
      totalReviews: map['total_reviews'] as int? ?? 0,
      correctCount: map['correct_count'] as int? ?? 0,
      accuracy: (map['accuracy'] as num?)?.toDouble() ?? 0.0,
      lastReviewed: map['last_reviewed'] != null 
          ? DateTime.parse(map['last_reviewed'] as String) 
          : null,
      timeSpent: map['time_spent'] as int? ?? 0,
    );
  }

  Vocab copyWith({
    String? id,
    String? word,
    String? pronunciation,
    String? meaning,
    String? example,
    String? exampleMeaning,
    String? note,
    String? categoryId,
    String? imagePath,
    DateTime? createdAt,
    int? familiarity,
    int? streak,
    DateTime? nextReview,
    int? totalReviews,
    int? correctCount,
    double? accuracy,
    DateTime? lastReviewed,
    int? timeSpent,
  }) {
    return Vocab(
      id: id ?? this.id,
      word: word ?? this.word,
      pronunciation: pronunciation ?? this.pronunciation,
      meaning: meaning ?? this.meaning,
      example: example ?? this.example,
      exampleMeaning: exampleMeaning ?? this.exampleMeaning,
      note: note ?? this.note,
      categoryId: categoryId ?? this.categoryId,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      familiarity: familiarity ?? this.familiarity,
      streak: streak ?? this.streak,
      nextReview: nextReview ?? this.nextReview,
      totalReviews: totalReviews ?? this.totalReviews,
      correctCount: correctCount ?? this.correctCount,
      accuracy: accuracy ?? this.accuracy,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      timeSpent: timeSpent ?? this.timeSpent,
    );
  }

  /// Kiểm tra trạng thái học của từ vựng
  String get studyStatus {
    if (totalReviews == 0) {
      return 'Chưa học';
    } else if (familiarity == 0) {
      return 'Mới';
    } else if (familiarity == 1) {
      return 'Đang học';
    } else if (familiarity == 2) {
      return 'Ôn tập';
    } else {
      return 'Đã thuộc';
    }
  }

  /// Màu sắc cho trạng thái
  int get statusColor {
    switch (studyStatus) {
      case 'Chưa học':
        return 0xFF9E9E9E; // Grey
      case 'Mới':
        return 0xFF2196F3; // Blue
      case 'Đang học':
        return 0xFFFF9800; // Orange
      case 'Ôn tập':
        return 0xFF4CAF50; // Green
      case 'Đã thuộc':
        return 0xFF9C27B0; // Purple
      default:
        return 0xFF9E9E9E;
    }
  }
}
