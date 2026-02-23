# Quiz Views

**File**: `lib/screens/quiz_views.dart`

Three different quiz mode widgets used by QuizScreen.

---

## FlashcardView

Self-assessment flashcard with flip animation.

### Features
- Tap to flip between front/back
- TTS speaker button
- AnimatedSwitcher for smooth flip
- Self-assessment buttons (Đã nhớ / Chưa nhớ)

### Layout
```
┌─────────────────────────┐
│                         │
│      사과               │  ← Front: Korean word
│      🔊                 │
│                         │
│   Chạm để xem đáp án    │
│                         │
└─────────────────────────┘
           ↓ Flip
┌─────────────────────────┐
│                         │
│     Quả táo            │  ← Back: Meaning
│   "사과를 먹어요"        │  ← Example
│         [Image]        │
│                         │
│  [Chưa nhớ] [Đã nhớ]   │
└─────────────────────────┘
```

### Props
- `vocab`: Vocab to display
- `onSelfAssess(bool isCorrect)`: Callback with result

---

## MCQView

Multiple choice with 4 options.

### Features
- 4 large tappable buttons
- Shuffled options (1 correct, 3 random)
- Immediate answer selection

### Layout
```
┌─────────────────────────┐
│        사과             │  ← Question
│     nghĩa là gì?       │
│                         │
│  [Quả cam]             │  ← Option 1
│  [Quả táo] ✓           │  ← Option 2 (correct)
│  [Quả chuối]           │  ← Option 3
│  [Quả nho]             │  ← Option 4
└─────────────────────────┘
```

### Props
- `vocab`: Vocab to quiz
- `options`: List of 4 strings
- `onAnswer(bool isCorrect)`: Callback with result

---

## TypingView

Text input for typing answer.

### Modes
1. **Normal**: See Korean, type Vietnamese meaning
2. **Reverse**: See Vietnamese, type Korean word

### Features
- Text input field
- Hint button (reveals answer)
- Check button
- Real-time validation

### Layout
```
┌─────────────────────────┐
│        사과             │  ← Prompt (Korean)
│   Gõ nghĩa tiếng Việt  │  ← Instruction
│                         │
│  ┌───────────────────┐ │
│  │  Quả táo...      │ │  ← Input field
│  └───────────────────┘ │
│                         │
│  [Gợi ý] [Kiểm tra]   │  ← Actions
└─────────────────────────┘
```

### Props
- `vocab`: Vocab to quiz
- `isReverse`: If true, reverse mode (see meaning, type Korean)
- `onAnswer(bool isCorrect)`: Callback with result

### Validation
- Case-insensitive comparison
- Partial match accepted (contains)
- Shows hint with correct answer
