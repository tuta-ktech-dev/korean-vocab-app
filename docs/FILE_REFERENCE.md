# Project File Reference

Complete list of all Dart files and their purposes.

## Core

| File | Purpose |
|------|---------|
| `lib/core/database/database_helper.dart` | SQLite database initialization and migrations |
| `lib/core/services/srs_service.dart` | Spaced Repetition System algorithm |

## Models

| File | Purpose |
|------|---------|
| `lib/models/category.dart` | Category data model |
| `lib/models/vocab.dart` | Vocabulary data model with SRS fields |
| `lib/models/quiz.dart` | Quiz session and enums |

## Repositories

| File | Purpose |
|------|---------|
| `lib/repositories/category_repository.dart` | Category CRUD operations |
| `lib/repositories/vocab_repository.dart` | Vocabulary CRUD operations |

## State Management (Cubits)

| File | Purpose |
|------|---------|
| `lib/cubits/category_cubit.dart` | Category list state management |
| `lib/cubits/category_state.dart` | Category states definition |
| `lib/cubits/vocab_cubit.dart` | Vocabulary list state management |
| `lib/cubits/vocab_state.dart` | Vocabulary states definition |
| `lib/cubits/quiz_cubit.dart` | Quiz session state management |
| `lib/cubits/quiz_state.dart` | Quiz states definition |

## UI Screens

| File | Purpose |
|------|---------|
| `lib/screens/home_screen.dart` | Main screen with categories |
| `lib/screens/add_category_screen.dart` | Create new category form |
| `lib/screens/category_detail_screen.dart` | View category vocabulary |
| `lib/screens/add_vocab_screen.dart` | Create new vocabulary form |
| `lib/screens/vocab_detail_screen.dart` | View vocabulary details |
| `lib/screens/study_screen.dart` | Flashcard study mode |
| `lib/screens/quiz_screen.dart` | Adaptive quiz screen |
| `lib/screens/quiz_views.dart` | Quiz mode widgets (Flashcard/MCQ/Typing) |
| `lib/screens/quiz_result_screen.dart` | Quiz session results |

## Entry Point

| File | Purpose |
|------|---------|
| `lib/main.dart` | App initialization and provider setup |

## Tests

| File | Purpose |
|------|---------|
| `test/core/services/srs_service_test.dart` | SRS algorithm unit tests |
| `test/models/category_test.dart` | Category model tests |
| `test/models/vocab_test.dart` | Vocabulary model tests |
| `test/models/quiz_test.dart` | Quiz model tests |

## Documentation

| File | Purpose |
|------|---------|
| `docs/README.md` | Project overview and architecture |
| `docs/architecture/database_helper.md` | Database documentation |
| `docs/architecture/cubits.md` | State management docs |
| `docs/services/srs_service.md` | SRS algorithm docs |
| `docs/data/models.md` | Data models documentation |
| `docs/data/repositories.md` | Repository layer docs |
| `docs/ui/screens.md` | Screen documentation |
| `docs/ui/quiz_views.md` | Quiz widget documentation |
| `docs/FILE_REFERENCE.md` | This file - complete file listing |
