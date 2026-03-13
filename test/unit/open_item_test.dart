import 'package:flutter_test/flutter_test.dart';
import 'package:nexuspoint_pos/core/models/menu_item.dart';

void main() {
  group('MenuItem.custom', () {
    test('creates item with custom_ prefix ID', () {
      final item = MenuItem.custom(name: 'Special Plate', price: 99.0);
      expect(item.id, startsWith('custom_'));
      expect(item.name, 'Special Plate');
      expect(item.price, 99.0);
      expect(item.sku, 'CUSTOM');
      expect(item.category, 'Open Item');
      expect(item.isAvailable, true);
    });

    test('isCustomItem returns true for custom items', () {
      final item = MenuItem.custom(name: 'Test', price: 10.0);
      expect(item.isCustomItem, true);
    });

    test('isCustomItem returns false for regular items', () {
      const item = MenuItem(
        id: 'uuid-123',
        sku: 'RICE-001',
        name: 'Fried Rice',
        price: 50.0,
      );
      expect(item.isCustomItem, false);
    });

    test('price must be positive', () {
      expect(
        () => MenuItem.custom(name: 'Bad', price: 0),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => MenuItem.custom(name: 'Bad', price: -5),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('name must not be empty', () {
      expect(
        () => MenuItem.custom(name: '', price: 10),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('trims whitespace from name', () {
      final item = MenuItem.custom(name: '  Extra Rice  ', price: 20.0);
      expect(item.name, 'Extra Rice');
    });
  });
}
