import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nexuspoint_pos/core/models/api_models.dart';

void main() {
  group('OrderItemDto — name field', () {
    test('serialises name to JSON', () {
      const dto = OrderItemDto(
        skuId: 'sku-pad-thai',
        name: 'Pad Thai',
        quantity: 2,
        unitPrice: 120.0,
      );

      final json = dto.toJson();

      expect(json['skuId'], 'sku-pad-thai');
      expect(json['name'], 'Pad Thai');
      expect(json['quantity'], 2);
      expect(json['unitPrice'], 120.0);
    });

    test('deserialises name from JSON', () {
      final json = {
        'skuId': 'sku-pad-thai',
        'name': 'Pad Thai',
        'quantity': 2,
        'unitPrice': 120.0,
      };

      final dto = OrderItemDto.fromJson(json);

      expect(dto.skuId, 'sku-pad-thai');
      expect(dto.name, 'Pad Thai');
      expect(dto.quantity, 2);
      expect(dto.unitPrice, 120.0);
    });

    test('name is optional — null when absent from JSON', () {
      final json = {
        'skuId': 'sku-xyz',
        'quantity': 1,
        'unitPrice': 50.0,
      };

      final dto = OrderItemDto.fromJson(json);

      expect(dto.name, isNull);
    });

    test('round-trip through JSON preserves name', () {
      const original = OrderItemDto(
        skuId: 'sku-1',
        name: 'Green Curry',
        quantity: 3,
        unitPrice: 150.0,
        notes: 'no spice',
      );

      final json = jsonEncode(original.toJson());
      final restored = OrderItemDto.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );

      expect(restored.name, 'Green Curry');
      expect(restored.notes, 'no spice');
      expect(restored.quantity, 3);
    });

    test('copyWith preserves name', () {
      const dto = OrderItemDto(
        skuId: 'sku-1',
        name: 'Tom Yum',
        quantity: 1,
        unitPrice: 80.0,
      );

      final updated = dto.copyWith(quantity: 3);

      expect(updated.name, 'Tom Yum');
      expect(updated.quantity, 3);
    });

    test('items stored as JSON during order creation include name', () {
      // Simulate what order_repository.dart does when writing itemsJson
      final items = [
        const OrderItemDto(
          skuId: 'sku-1',
          name: 'Pad Thai',
          quantity: 2,
          unitPrice: 120.0,
        ),
        const OrderItemDto(
          skuId: 'sku-2',
          name: 'Spring Roll',
          quantity: 1,
          unitPrice: 60.0,
        ),
      ];

      final itemsJson = jsonEncode(items.map((e) => e.toJson()).toList());

      // Simulate what _localToModel does when reading itemsJson back
      final restored = (jsonDecode(itemsJson) as List)
          .map((e) => OrderItemDto.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(restored[0].name, 'Pad Thai');
      expect(restored[1].name, 'Spring Roll');
    });
  });
}
