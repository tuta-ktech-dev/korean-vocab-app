# Repositories

Data access layer between Cubits and Database.

---

## CategoryRepository

**File**: `lib/repositories/category_repository.dart`

Handles CRUD operations for categories.

### Methods

#### `getAllCategories() → Future<List<Category>>`
Returns all categories from database.

#### `getCategory(String id) → Future<Category?>`
Returns single category by ID.

#### `insertCategory(Category category) → Future<void>`
Inserts new category.

#### `updateCategory(Category category) → Future<void>`
Updates existing category.

#### `deleteCategory(String id) → Future<void>`
Deletes category by ID.

---

## VocabRepository

**File**: `lib/repositories/vocab_repository.dart`

Handles CRUD operations for vocabulary with SRS support.

### Methods

#### `getAllVocabs() → Future<List<Vocab>>`
Returns all vocabulary items.

#### `getVocabsByCategory(String categoryId) → Future<List<Vocab>>`
Returns vocabulary filtered by category.

#### `getVocab(String id) → Future<Vocab?>`
Returns single vocabulary by ID.

#### `insertVocab(Vocab vocab) → Future<void>`
Inserts new vocabulary.

#### `updateVocab(Vocab vocab) → Future<void>`
Updates existing vocabulary (used after quiz for SRS fields).

#### `deleteVocab(String id) → Future<void>`
Deletes vocabulary by ID.

## Data Mapping

Repositories handle conversion between:
- **Database rows** (Map<String, dynamic>)
- **Model objects** (Category, Vocab)

Example:
```dart
// From database
final maps = await db.query('categories');
return maps.map(Category.fromMap).toList();

// To database
await db.insert('categories', category.toMap());
```
