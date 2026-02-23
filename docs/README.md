# Korean Vocab App - Architecture Overview

## Project Structure

```
lib/
├── core/              # Core infrastructure
│   ├── database/      # Database helper
│   └── services/      # Business logic services (SRS)
├── models/            # Data models
├── repositories/      # Data access layer
├── cubits/            # State management (BLoC pattern)
├── screens/           # UI screens
└── main.dart          # App entry point
```

## Technology Stack

- **Framework**: Flutter (Cupertino design for iOS-style)
- **State Management**: flutter_bloc (Cubit pattern)
- **Database**: SQLite via sqflite
- **DI**: get_it
- **TTS**: flutter_tts (Korean pronunciation)

## Key Features

1. **Smart SRS System**: Adaptive quiz difficulty based on familiarity
2. **4 Quiz Modes**: Flashcard, MCQ, Typing, Reverse Typing
3. **Spaced Repetition**: Auto-scheduled review intervals
4. **Custom Content**: User-defined categories and vocabulary

## Data Flow

```
UI (Screens) 
    ↕
Cubits (State Management)
    ↕
Repositories (Data Access)
    ↕
Database (SQLite)
```

## Database Schema

### categories
- id (TEXT PK)
- name (TEXT)
- name_korean (TEXT)
- image_path (TEXT)

### vocabularies
- id (TEXT PK)
- word (TEXT) - Korean word
- meaning (TEXT) - Vietnamese meaning
- example (TEXT) - Korean example sentence
- example_meaning (TEXT) - Vietnamese translation
- note (TEXT) - User notes (markdown supported)
- category_id (TEXT FK)
- image_path (TEXT)
- created_at (TEXT)
- familiarity (INTEGER) - 0-5 level
- streak (INTEGER)
- next_review (TEXT) - ISO8601 datetime
- total_reviews (INTEGER)
- correct_count (INTEGER)
- accuracy (REAL)
- last_reviewed (TEXT)
- time_spent (INTEGER)

## SRS Algorithm

See [SRS Service Documentation](services/srs_service.md)

## Getting Started

1. Run `flutter pub get`
2. Run `flutter run` for development
3. Run `flutter test` for unit tests
4. Run `flutter build apk --release` for Android release
