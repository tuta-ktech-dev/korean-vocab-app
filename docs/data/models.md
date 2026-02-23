# Models

## Category

**File**: `lib/models/category.dart`

Represents a vocabulary category (e.g., Food, Travel, etc.)

### Fields
- `id` (String): Unique identifier
- `name` (String): Display name (Vietnamese)
- `nameKorean` (String?): Korean name (optional)
- `imagePath` (String?): Local image path (optional)

### Methods
- `fromMap()`: Deserialize from database
- `toMap()`: Serialize for database
- `copyWith()`: Immutable copy with field updates

---

## Vocab

**File**: `lib/models/vocab.dart`

Represents a Korean vocabulary item with full SRS tracking.

### Core Fields
- `id` (String): Unique identifier
- `word` (String): Korean word (e.g., "사과")
- `meaning` (String): Vietnamese meaning (e.g., "Quả táo")
- `example` (String?): Example sentence in Korean
- `exampleMeaning` (String?): Vietnamese translation of example
- `note` (String?): User notes (supports markdown)
- `categoryId` (String): Parent category ID
- `imagePath` (String?): Local image path
- `createdAt` (DateTime): Creation timestamp

### SRS Fields
- `familiarity` (int): 0-5 mastery level
- `streak` (int): Consecutive correct answers
- `nextReview` (DateTime?): Scheduled review time
- `totalReviews` (int): Total times reviewed
- `correctCount` (int): Times answered correctly
- `accuracy` (double): Success rate (0.0-1.0)
- `lastReviewed` (DateTime?): Last review timestamp
- `timeSpent` (int): Seconds spent learning

### Methods
- `fromMap()`: Deserialize from database
- `toMap()`: Serialize for database
- `copyWith()`: Immutable copy with field updates

---

## Quiz Models

**File**: `lib/models/quiz.dart`

### QuizMode Enum
- `flashcard`: View and self-assess
- `mcq`: Multiple choice (4 options)
- `typing`: Type the answer
- `reverseTyping`: See meaning, type Korean

### QuizResult Enum
- `correct`: Answered correctly
- `incorrect`: Answered incorrectly
- `hint`: Used hint
- `skip`: Skipped question

### QuizSession Class
Tracks a single practice session.

**Fields:**
- `id` (String): Session ID
- `startedAt` (DateTime): Start time
- `vocabIds` (List<String>): Vocabulary in session
- `currentIndex` (int): Current position
- `correctCount` (int): Correct answers
- `incorrectCount` (int): Incorrect answers
- `skippedCount` (int): Skipped questions
- `vocabModes` (Map): Mode used for each vocab
- `vocabAttempts` (Map): Number of attempts per vocab

**Methods:**
- `accuracy`: Calculate success rate
- `isComplete`: Check if session finished
- `currentVocabId`: Get current vocabulary ID
