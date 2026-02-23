class Category {
  final String id;
  final String name;        // Tên tiếng Việt
  final String? nameKorean; // Tên tiếng Hàn
  final String? imagePath;  // Ảnh thay vì emoji

  Category({
    required this.id,
    required this.name,
    this.nameKorean,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'name_korean': nameKorean,
      'image_path': imagePath,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      nameKorean: map['name_korean'] as String?,
      imagePath: map['image_path'] as String?,
    );
  }

  Category copyWith({
    String? id,
    String? name,
    String? nameKorean,
    String? imagePath,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      nameKorean: nameKorean ?? this.nameKorean,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
