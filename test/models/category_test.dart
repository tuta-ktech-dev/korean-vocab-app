import 'package:flutter_test/flutter_test.dart';
import 'package:korean_vocab/models/category.dart';

void main() {
  group('Category Model', () {
    test('should create category from map correctly', () {
      final map = {
        'id': '1',
        'name': 'Thực phẩm',
        'name_korean': '음식',
        'image_path': '/path/to/image.jpg',
      };
      
      final category = Category.fromMap(map);
      
      expect(category.id, '1');
      expect(category.name, 'Thực phẩm');
      expect(category.nameKorean, '음식');
      expect(category.imagePath, '/path/to/image.jpg');
    });

    test('should convert category to map correctly', () {
      final category = Category(
        id: '1',
        name: 'Thực phẩm',
        nameKorean: '음식',
        imagePath: '/path/to/image.jpg',
      );
      
      final map = category.toMap();
      
      expect(map['id'], '1');
      expect(map['name'], 'Thực phẩm');
      expect(map['name_korean'], '음식');
      expect(map['image_path'], '/path/to/image.jpg');
    });

    test('should handle null values', () {
      final map = {
        'id': '1',
        'name': 'Thực phẩm',
        'name_korean': null,
        'image_path': null,
      };
      
      final category = Category.fromMap(map);
      
      expect(category.nameKorean, null);
      expect(category.imagePath, null);
    });

    test('copyWith should update fields', () {
      final category = Category(
        id: '1',
        name: 'Thực phẩm',
        nameKorean: '음식',
      );
      
      final updated = category.copyWith(name: 'Đồ ăn');
      
      expect(updated.id, '1');
      expect(updated.name, 'Đồ ăn');
      expect(updated.nameKorean, '음식');
    });

    test('copyWith should keep original values if not provided', () {
      final category = Category(
        id: '1',
        name: 'Thực phẩm',
        nameKorean: '음식',
      );
      
      final updated = category.copyWith();
      
      expect(updated.id, '1');
      expect(updated.name, 'Thực phẩm');
      expect(updated.nameKorean, '음식');
    });
  });
}
