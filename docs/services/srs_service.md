# SRS Service

**File**: `lib/core/services/srs_service.dart`

## Purpose

Implements Spaced Repetition System (SRS) algorithm for optimal vocabulary learning.

## Key Responsibilities

1. **Calculate next review date** based on quiz result
2. **Determine quiz difficulty** (mode) based on familiarity
3. **Track learning progress** via familiarity levels
4. **Filter due vocabulary** for daily practice

## Familiarity Levels

| Level | Name | Interval | Quiz Mode |
|-------|------|----------|-----------|
| 0 | New | 10 min | Flashcard |
| 1 | Learning | 1 day | MCQ |
| 2 | Review | 3 days | Typing/MCQ |
| 3 | Mastered I | 1 week | Typing/Reverse |
| 4 | Mastered II | 2 weeks | Reverse |
| 5 | Mastered III | 1 month | Reverse |

## Quiz Modes

- **Flashcard**: View word, self-assess (easiest)
- **MCQ**: Multiple choice from 4 options
- **Typing**: Type the answer
- **ReverseTyping**: See meaning, type Korean word (hardest)

## Adaptive Difficulty

The service automatically adjusts difficulty:

```
User answers correctly × 2 → Level up
User answers incorrectly → Level down
Multiple failures → Fallback to easier mode
```

## Algorithm Details

### Next Review Calculation

```dart
Correct:   baseInterval × (1 + streak × 0.3)
Incorrect: 10 minutes (reset)
Hint:      1 hour
Skip:      30 minutes
```

### Streak Multiplier

Each consecutive correct answer increases interval by 30%.

Example with familiarity=2 (3 days base):
- Streak 0: 3 days
- Streak 1: 3.9 days
- Streak 2: 4.8 days

## Public Methods

### `calculateNextReview(Vocab vocab, QuizResult result)`
Returns `DateTime` for next review based on quiz result.

### `determineQuizMode(Vocab vocab, int attempts)`
Returns `QuizMode` based on familiarity and failed attempts.

### `getDueVocabs(List<Vocab> vocabs, {int limit})`
Returns list of vocabulary due for review, sorted by priority.

### `calculateAccuracy(int correct, int total)`
Returns accuracy percentage (0.0 - 1.0).

## Usage Example

```dart
final srs = SRSService();

// After quiz
final nextReview = srs.calculateNextReview(vocab, QuizResult.correct);

// Get quiz mode
final mode = srs.determineQuizMode(vocab, 0);

// Get today's due items
final due = srs.getDueVocabs(allVocabs, limit: 20);
```
