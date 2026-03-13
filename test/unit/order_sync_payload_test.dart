import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nexuspoint_pos/core/models/api_models.dart';

// ---------------------------------------------------------------------------
// Tests for the order sync payload fixes:
//   1. BackendOrderItemDto uses menuItemId + price (string), not skuId + unitPrice
//   2. OrderRequest uses subtotal/total (strings), not totalAmount (double)
//   3. Null optional fields are present in toJson (stripped by API layer)
//   4. Old-format sync queue payloads deserialize via normalize functions
//   5. BackendOrderItemDto.fromOrderItemDto conversion
//   6. Full round-trip: OrderRequest → JSON → OrderRequest
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // BackendOrderItemDto — serialization matches Zod schema
  // -------------------------------------------------------------------------
  group('BackendOrderItemDto — toJson matches Zod schema', () {
    test('uses menuItemId not skuId', () {
      const item = BackendOrderItemDto(
        menuItemId: 'item-uuid-1',
        name: 'Pad Thai',
        quantity: 2,
        price: '80.00',
      );

      final json = item.toJson();

      expect(json['menuItemId'], 'item-uuid-1');
      expect(json.containsKey('skuId'), false);
    });

    test('price is a string not a double', () {
      const item = BackendOrderItemDto(
        menuItemId: 'item-uuid-1',
        name: 'Pad Thai',
        quantity: 1,
        price: '120.50',
      );

      final json = item.toJson();

      expect(json['price'], isA<String>());
      expect(json['price'], '120.50');
      expect(json.containsKey('unitPrice'), false);
    });

    test('notes field is present when provided', () {
      const item = BackendOrderItemDto(
        menuItemId: 'item-1',
        name: 'Green Curry',
        quantity: 1,
        price: '95.00',
        notes: 'Extra spicy',
      );

      final json = item.toJson();

      expect(json['notes'], 'Extra spicy');
    });

    test('notes field is null in toJson when absent (API layer strips it)', () {
      const item = BackendOrderItemDto(
        menuItemId: 'item-1',
        name: 'Green Curry',
        quantity: 1,
        price: '95.00',
      );

      final json = item.toJson();

      // Freezed includes null — the API _stripNulls removes it before sending
      expect(json.containsKey('notes'), true);
      expect(json['notes'], isNull);
    });
  });

  // -------------------------------------------------------------------------
  // BackendOrderItemDto.fromOrderItemDto — conversion from local DTO
  // -------------------------------------------------------------------------
  group('BackendOrderItemDto.fromOrderItemDto — conversion', () {
    test('maps skuId to menuItemId', () {
      const local = OrderItemDto(
        skuId: 'SKU-001',
        name: 'Tom Yum',
        quantity: 3,
        unitPrice: 150.0,
      );

      final backend = BackendOrderItemDto.fromOrderItemDto(local);

      expect(backend.menuItemId, 'SKU-001');
    });

    test('converts unitPrice (double) to price (string with 2 decimals)', () {
      const local = OrderItemDto(
        skuId: 'SKU-001',
        name: 'Tom Yum',
        quantity: 1,
        unitPrice: 150.0,
      );

      final backend = BackendOrderItemDto.fromOrderItemDto(local);

      expect(backend.price, '150.00');
    });

    test('handles fractional prices correctly', () {
      const local = OrderItemDto(
        skuId: 'SKU-002',
        name: 'Side Dish',
        quantity: 1,
        unitPrice: 29.99,
      );

      final backend = BackendOrderItemDto.fromOrderItemDto(local);

      expect(backend.price, '29.99');
    });

    test('preserves name, quantity, and notes', () {
      const local = OrderItemDto(
        skuId: 'SKU-003',
        name: 'Mango Sticky Rice',
        quantity: 2,
        unitPrice: 60.0,
        notes: 'No coconut milk',
      );

      final backend = BackendOrderItemDto.fromOrderItemDto(local);

      expect(backend.name, 'Mango Sticky Rice');
      expect(backend.quantity, 2);
      expect(backend.notes, 'No coconut milk');
    });

    test('uses skuId as name fallback when name is null', () {
      const local = OrderItemDto(
        skuId: 'SKU-UNNAMED',
        quantity: 1,
        unitPrice: 10.0,
      );

      final backend = BackendOrderItemDto.fromOrderItemDto(local);

      expect(backend.name, 'SKU-UNNAMED');
    });

    test('custom item uses empty menuItemId', () {
      const dto = OrderItemDto(
        skuId: 'custom_1234567890',
        name: 'Special Plate',
        quantity: 1,
        unitPrice: 99.0,
      );

      final backend = BackendOrderItemDto.fromOrderItemDto(dto);
      expect(backend.menuItemId, '');
      expect(backend.name, 'Special Plate');
    });
  });

  // -------------------------------------------------------------------------
  // OrderRequest — toJson matches Zod schema
  // -------------------------------------------------------------------------
  group('OrderRequest — toJson matches Zod schema', () {
    test('uses subtotal and total as strings, not totalAmount', () {
      const req = OrderRequest(
        branchId: 'branch-1',
        source: 'pos',
        items: [],
        subtotal: '250.00',
        total: '250.00',
      );

      final json = req.toJson();

      expect(json['subtotal'], '250.00');
      expect(json['total'], '250.00');
      expect(json.containsKey('totalAmount'), false);
    });

    test('does not include tenantId field', () {
      const req = OrderRequest(
        branchId: 'branch-1',
        source: 'pos',
        items: [],
        subtotal: '100.00',
        total: '100.00',
      );

      final json = req.toJson();

      expect(json.containsKey('tenantId'), false);
    });

    test('does not include paymentMethod field', () {
      const req = OrderRequest(
        branchId: 'branch-1',
        source: 'pos',
        items: [],
        subtotal: '100.00',
        total: '100.00',
      );

      final json = req.toJson();

      expect(json.containsKey('paymentMethod'), false);
    });

    test('does not include tableNumber field', () {
      const req = OrderRequest(
        branchId: 'branch-1',
        source: 'pos',
        items: [],
        subtotal: '100.00',
        total: '100.00',
      );

      final json = req.toJson();

      expect(json.containsKey('tableNumber'), false);
    });

    test('serializes items as BackendOrderItemDto (menuItemId, price string)', () {
      const req = OrderRequest(
        branchId: 'branch-1',
        source: 'pos',
        items: [
          BackendOrderItemDto(
            menuItemId: 'item-uuid',
            name: 'Pad Thai',
            quantity: 2,
            price: '80.00',
          ),
        ],
        subtotal: '160.00',
        total: '160.00',
      );

      // Round-trip through JSON to get pure maps (like Dio/jsonEncode does)
      final json = jsonDecode(jsonEncode(req.toJson())) as Map<String, dynamic>;
      final items = json['items'] as List;

      expect(items, hasLength(1));
      final item = items[0] as Map<String, dynamic>;
      expect(item['menuItemId'], 'item-uuid');
      expect(item['price'], '80.00');
      expect(item.containsKey('skuId'), false);
      expect(item.containsKey('unitPrice'), false);
    });

    test('discount and notes are null when absent (stripped by API layer)', () {
      const req = OrderRequest(
        branchId: 'branch-1',
        source: 'pos',
        items: [],
        subtotal: '100.00',
        total: '100.00',
      );

      final json = req.toJson();

      // Freezed includes null for optional fields; API _stripNulls removes them
      expect(json.containsKey('discount'), true);
      expect(json['discount'], isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Full payload round-trip: simulates what sync_service does
  // -------------------------------------------------------------------------
  group('OrderRequest — full JSON round-trip (sync queue simulation)', () {
    test('new-format payload survives encode/decode', () {
      const req = OrderRequest(
        branchId: 'branch-uuid',
        source: 'pos',
        items: [
          BackendOrderItemDto(
            menuItemId: 'menu-item-1',
            name: 'Green Curry',
            quantity: 1,
            price: '120.00',
            notes: 'Mild',
          ),
          BackendOrderItemDto(
            menuItemId: 'menu-item-2',
            name: 'Rice',
            quantity: 2,
            price: '20.00',
          ),
        ],
        subtotal: '160.00',
        total: '160.00',
      );

      // Simulate what order_repository.createOrder does:
      final payloadJson = jsonEncode(req.toJson());

      // Simulate what sync_service._syncOrder does:
      final decoded = jsonDecode(payloadJson) as Map<String, dynamic>;
      final restored = OrderRequest.fromJson(decoded);

      expect(restored.branchId, 'branch-uuid');
      expect(restored.source, 'pos');
      expect(restored.subtotal, '160.00');
      expect(restored.total, '160.00');
      expect(restored.items, hasLength(2));
      expect(restored.items[0].menuItemId, 'menu-item-1');
      expect(restored.items[0].price, '120.00');
      expect(restored.items[0].notes, 'Mild');
      expect(restored.items[1].menuItemId, 'menu-item-2');
      expect(restored.items[1].price, '20.00');
      expect(restored.items[1].notes, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Old-format backward compatibility (queue items from before the fix)
  // -------------------------------------------------------------------------
  group('BackendOrderItemDto — old-format normalization', () {
    test('normalizes skuId to menuItemId', () {
      final oldItem = {
        'skuId': 'SKU-OLD-1',
        'name': 'Old Menu Item',
        'quantity': 1,
        'unitPrice': 75.0,
      };

      final item = BackendOrderItemDto.fromJson(oldItem);

      expect(item.menuItemId, 'SKU-OLD-1');
    });

    test('normalizes unitPrice (double) to price (string)', () {
      final oldItem = {
        'skuId': 'SKU-OLD-2',
        'name': 'Old Item',
        'quantity': 1,
        'unitPrice': 99.5,
      };

      final item = BackendOrderItemDto.fromJson(oldItem);

      expect(item.price, '99.50');
    });

    test('preserves new-format fields unchanged', () {
      final newItem = {
        'menuItemId': 'uuid-new',
        'name': 'New Item',
        'quantity': 3,
        'price': '42.00',
        'notes': 'Extra sauce',
      };

      final item = BackendOrderItemDto.fromJson(newItem);

      expect(item.menuItemId, 'uuid-new');
      expect(item.price, '42.00');
      expect(item.notes, 'Extra sauce');
    });

    test('uses skuId as name fallback when name is absent', () {
      final oldItem = {
        'skuId': 'SKU-NONAME',
        'quantity': 1,
        'unitPrice': 10.0,
      };

      final item = BackendOrderItemDto.fromJson(oldItem);

      expect(item.name, 'SKU-NONAME');
    });
  });

  group('OrderRequest — old-format normalization', () {
    test('maps totalAmount (double) to subtotal and total (strings)', () {
      final oldPayload = {
        'tenantId': 'org-old',
        'branchId': 'branch-old',
        'source': 'pos',
        'items': <dynamic>[],
        'totalAmount': 250.0,
        'paymentMethod': 'cash',
        'tableNumber': 'T1',
      };

      final req = OrderRequest.fromJson(oldPayload);

      expect(req.subtotal, '250.00');
      expect(req.total, '250.00');
      expect(req.source, 'pos');
      expect(req.branchId, 'branch-old');
    });

    test('old items with skuId/unitPrice deserialize inside OrderRequest', () {
      final oldPayload = {
        'tenantId': 'org-old',
        'branchId': 'branch-old',
        'source': 'grab',
        'items': [
          {
            'skuId': 'SKU-IN-REQ',
            'name': 'Pad See Ew',
            'quantity': 2,
            'unitPrice': 85.0,
          },
        ],
        'totalAmount': 170.0,
        'paymentMethod': 'card',
      };

      final req = OrderRequest.fromJson(oldPayload);

      expect(req.items, hasLength(1));
      expect(req.items[0].menuItemId, 'SKU-IN-REQ');
      expect(req.items[0].name, 'Pad See Ew');
      expect(req.items[0].price, '85.00');
      expect(req.items[0].quantity, 2);
    });

    test('preserves new-format subtotal/total when already present', () {
      final newPayload = {
        'branchId': 'branch-new',
        'source': 'pos',
        'items': <dynamic>[],
        'subtotal': '300.00',
        'total': '300.00',
      };

      final req = OrderRequest.fromJson(newPayload);

      expect(req.subtotal, '300.00');
      expect(req.total, '300.00');
    });
  });

  // -------------------------------------------------------------------------
  // F-003: New fields in OrderRequest (orderType, tableId, createdBy, VAT)
  // -------------------------------------------------------------------------
  group('OrderRequest — F-003 new fields', () {
    test('includes orderType, tableId, createdBy in toJson', () {
      const req = OrderRequest(
        branchId: 'branch-1',
        source: 'pos',
        orderType: 'dine_in',
        tableId: 'table-uuid-123',
        createdBy: 'staff-uuid-456',
        items: [],
        subtotal: '310.00',
        total: '331.70',
      );

      final json = req.toJson();

      expect(json['orderType'], 'dine_in');
      expect(json['tableId'], 'table-uuid-123');
      expect(json['createdBy'], 'staff-uuid-456');
    });

    test('includes vatAmount and vatRate in toJson', () {
      const req = OrderRequest(
        branchId: 'branch-1',
        source: 'pos',
        vatAmount: '21.70',
        vatRate: '7.00',
        items: [],
        subtotal: '310.00',
        total: '331.70',
      );

      final json = req.toJson();

      expect(json['vatAmount'], '21.70');
      expect(json['vatRate'], '7.00');
    });

    test('new fields are null when not provided', () {
      const req = OrderRequest(
        branchId: 'branch-1',
        source: 'pos',
        items: [],
        subtotal: '100.00',
        total: '100.00',
      );

      final json = req.toJson();

      expect(json['orderType'], isNull);
      expect(json['tableId'], isNull);
      expect(json['createdBy'], isNull);
      expect(json['vatAmount'], isNull);
      expect(json['vatRate'], isNull);
    });

    test('new fields survive round-trip', () {
      const req = OrderRequest(
        branchId: 'branch-1',
        source: 'pos',
        orderType: 'takeaway',
        createdBy: 'staff-1',
        vatAmount: '7.00',
        vatRate: '7.00',
        items: [],
        subtotal: '100.00',
        total: '107.00',
      );

      final payloadJson = jsonEncode(req.toJson());
      final decoded = jsonDecode(payloadJson) as Map<String, dynamic>;
      final restored = OrderRequest.fromJson(decoded);

      expect(restored.orderType, 'takeaway');
      expect(restored.createdBy, 'staff-1');
      expect(restored.vatAmount, '7.00');
      expect(restored.vatRate, '7.00');
    });
  });

  // -------------------------------------------------------------------------
  // Null stripping simulation — verifies what _stripNulls does
  // -------------------------------------------------------------------------
  group('Null-stripping behavior (simulates API _stripNulls)', () {
    /// Mirrors the private _stripNulls function in api_service.dart
    Map<String, dynamic> stripNulls(Map<String, dynamic> map) {
      final result = <String, dynamic>{};
      for (final entry in map.entries) {
        if (entry.value == null) continue;
        if (entry.value is Map<String, dynamic>) {
          result[entry.key] = stripNulls(entry.value as Map<String, dynamic>);
        } else if (entry.value is List) {
          result[entry.key] = (entry.value as List).map((item) {
            if (item is Map<String, dynamic>) return stripNulls(item);
            return item;
          }).toList();
        } else {
          result[entry.key] = entry.value;
        }
      }
      return result;
    }

    test('removes top-level null values', () {
      final input = {'a': 'hello', 'b': null, 'c': 42};
      final result = stripNulls(input);

      expect(result, {'a': 'hello', 'c': 42});
      expect(result.containsKey('b'), false);
    });

    test('removes nested null values in maps', () {
      final input = {
        'outer': {'keep': 'yes', 'drop': null},
      };
      final result = stripNulls(input);

      expect(result, {
        'outer': {'keep': 'yes'},
      });
    });

    test('removes null values inside list items', () {
      final input = {
        'items': [
          {'name': 'A', 'notes': null},
          {'name': 'B', 'notes': 'spicy'},
        ],
      };
      final result = stripNulls(input);

      expect(result, {
        'items': [
          {'name': 'A'},
          {'name': 'B', 'notes': 'spicy'},
        ],
      });
    });

    test('OrderRequest.toJson after stripNulls omits discount and notes', () {
      const req = OrderRequest(
        branchId: 'branch-1',
        source: 'pos',
        items: [
          BackendOrderItemDto(
            menuItemId: 'item-1',
            name: 'Pad Thai',
            quantity: 1,
            price: '100.00',
            // notes deliberately omitted (null)
          ),
        ],
        subtotal: '100.00',
        total: '100.00',
        // discount deliberately omitted (null)
        // notes deliberately omitted (null)
      );

      // Round-trip through JSON to get pure maps (like Dio does before sending)
      final pureJson = jsonDecode(jsonEncode(req.toJson())) as Map<String, dynamic>;
      final stripped = stripNulls(pureJson);

      // Top-level: discount and notes removed
      expect(stripped.containsKey('discount'), false);
      expect(stripped.containsKey('notes'), false);

      // Items: notes removed from first item
      final items = stripped['items'] as List;
      final item = items[0] as Map<String, dynamic>;
      expect(item.containsKey('notes'), false);
      expect(item['menuItemId'], 'item-1');
      expect(item['price'], '100.00');
    });

    test('OrderRequest.toJson after stripNulls preserves non-null optionals', () {
      const req = OrderRequest(
        branchId: 'branch-1',
        source: 'pos',
        items: [
          BackendOrderItemDto(
            menuItemId: 'item-1',
            name: 'Pad Thai',
            quantity: 1,
            price: '100.00',
            notes: 'Extra lime',
          ),
        ],
        subtotal: '100.00',
        total: '100.00',
        discount: '10.00',
        notes: 'VIP table',
      );

      // Round-trip through JSON to get pure maps (like Dio does before sending)
      final pureJson = jsonDecode(jsonEncode(req.toJson())) as Map<String, dynamic>;
      final stripped = stripNulls(pureJson);

      expect(stripped['discount'], '10.00');
      expect(stripped['notes'], 'VIP table');

      final items = stripped['items'] as List;
      final item = items[0] as Map<String, dynamic>;
      expect(item['notes'], 'Extra lime');
    });
  });
}
