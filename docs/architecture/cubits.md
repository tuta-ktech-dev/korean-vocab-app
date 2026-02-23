# State Management (Cubits)

## Overview

Uses BLoC pattern with Cubits for state management.

---

## CategoryCubit

**File**: `lib/cubits/category_cubit.dart`
**State**: `lib/cubits/category_state.dart`

### States
- `CategoryInitial`: Initial state
- `CategoryLoading`: Loading data
- `CategoryLoaded(List<Category>)`: Data loaded
- `CategoryError(String)`: Error occurred

### Methods
- `loadCategories()`: Fetch all categories
- `addCategory(name, {nameKorean, imagePath})`: Create new category
- `deleteCategory(id)`: Remove category

---

## VocabCubit

**File**: `lib/cubits/vocab_cubit.dart`
**State**: `lib/cubits/vocab_state.dart`

### States
- `VocabInitial`: Initial state
- `VocabLoading`: Loading data
- `VocabLoaded(List<Vocab>)`: Data loaded
- `VocabError(String)`: Error occurred

### Methods
- `loadVocabs({categoryId})`: Fetch vocabularies (all or by category)
- `addVocab(...)`: Create new vocabulary with optional image
- `deleteVocab(id, {categoryId})`: Remove vocabulary

**Image Handling:**
- Saves image to app documents directory
- Generates unique filename
- Stores path in database

---

## QuizCubit

**File**: `lib/cubits/quiz_cubit.dart`
**State**: `lib/cubits/quiz_state.dart`

Manages entire quiz session with adaptive difficulty.

### States
- `QuizInitial`: Ready to start
- `QuizLoading`: Loading vocabulary
- `QuizNoVocabs(String)`: No due items
- `QuizQuestion(vocab, mode, session, options, progress)`: Show question
- `QuizFeedback(vocab, result, nextReview)`: Show answer feedback
- `QuizComplete(session)`: Session finished
- `QuizError(String)`: Error occurred

### Methods

#### `startSession({categoryId, limit})`
Starts new quiz session:
1. Loads vocabulary from database
2. Filters due items using SRS service
3. Creates QuizSession
4. Shows first question

#### `submitAnswer(QuizResult)`
Processes user's answer:
1. Updates session stats
2. Calculates next review date via SRS
3. Updates vocabulary in database
4. Shows feedback screen

#### `nextQuestion()`
Advances to next question or completes session.

#### `reset()`
Clears current session.

### Quiz Mode Selection

Automatically determines mode:
```dart
if (attempts >= 2) return QuizMode.flashcard;
switch (familiarity) {
  case 0: return QuizMode.flashcard;
  case 1: return QuizMode.mcq;
  case 2: return attempts > 0 ? QuizMode.mcq : QuizMode.typing;
  default: return QuizMode.reverseTyping;
}
```

### MCQ Generation

Generates 4 options for multiple choice:
- 1 correct answer
- 3 random distractors from other vocabularies
- Shuffled order
