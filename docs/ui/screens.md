# UI Screens

## Home Screen

**File**: `lib/screens/home_screen.dart`

Main screen showing categories and action buttons.

### Features
- Display list of categories with images
- "Luyện tập thông minh" button → QuizScreen
- "Học flashcard" button → StudyScreen
- Add category button (+)

### UI Elements
- CupertinoNavigationBar with title
- CupertinoButton.filled for primary actions
- CupertinoListTile for category list

---

## Add Category Screen

**File**: `lib/screens/add_category_screen.dart`

Form to create new category.

### Fields
- Name (Vietnamese) - required
- Name Korean - optional
- Image picker - optional

### Actions
- Cancel: Discard and go back
- Save: Create category

---

## Category Detail Screen

**File**: `lib/screens/category_detail_screen.dart`

Shows vocabulary in a category.

### Features
- List of vocabulary with thumbnails
- Tap to view detail
- Swipe/delete option
- Add vocabulary button (+)

---

## Add Vocab Screen

**File**: `lib/screens/add_vocab_screen.dart`

Form to create new vocabulary.

### Fields
- Word (Korean) - required
- Meaning (Vietnamese) - required
- Example sentence (Korean) - optional
- Example meaning (Vietnamese) - optional
- Note (markdown supported) - optional
- Image picker - optional

---

## Vocab Detail Screen

**File**: `lib/screens/vocab_detail_screen.dart`

Full view of vocabulary with all info.

### Features
- Large word display
- Meaning
- Example with translation
- Image (if exists)
- Notes section
- "Phát âm" button (TTS)

---

## Study Screen (Flashcard)

**File**: `lib/screens/study_screen.dart`

Simple flashcard mode for learning.

### Features
- Flip card animation (front/back)
- TTS pronunciation button
- Next/previous navigation
- Progress indicator

### Card Front
- Korean word
- Speaker button
- "Chạm để lật" hint

### Card Back
- Vietnamese meaning
- Example sentence (if exists)

---

## Quiz Screen

**File**: `lib/screens/quiz_screen.dart`

Adaptive quiz with multiple modes.

### States
1. **Question**: Shows quiz based on current mode
2. **Feedback**: Shows result and correct answer

### Quiz Views

#### FlashcardView
- Self-assessment
- "Chưa nhớ" / "Đã nhớ" buttons

#### MCQView
- 4 option buttons
- Immediate selection

#### TypingView
- Text input field
- Hint button
- Check button

### Progress Bar
- Shows current/total
- Percentage complete

### Mode Indicator
- Colored badge showing current mode

---

## Quiz Result Screen

**File**: `lib/screens/quiz_result_screen.dart`

Session completion summary.

### Display
- Accuracy percentage (large)
- Correct/Incorrect/Skipped counts
- Encouragement message based on score:
  - >= 90%: "Xuất sắc! 🌟"
  - >= 70%: "Rất tốt! 👍"
  - >= 50%: "Khá tốt! 💪"
  - < 50%: "Cố lên! 🎯"

### Actions
- "Hoàn thành" button to return home
