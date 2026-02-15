import 'package:flutter_test/flutter_test.dart';
import 'package:nexuspoint_pos/core/models/order.dart';
import 'package:nexuspoint_pos/core/models/api_models.dart';

// ---------------------------------------------------------------------------
// Tests for backend enum mappings and OrderResponse normalization.
// Covers the fixes for:
//   - order.create 404 (backend not implemented)
//   - source mismatch: Flutter 'dinein' → backend 'pos'
//   - status mismatch: Flutter 'confirmed/delivered' ↔ backend 'accepted/completed'
//   - OrderResponse field normalization (id/orderId, total/totalAmount, snake_case)
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // OrderSource backend mapping
  // -------------------------------------------------------------------------
  group('OrderSourceBackend — toBackendValue', () {
    test('dinein maps to pos', () {
      expect(OrderSource.dinein.backendValue, 'pos');
    });

    test('grab maps to grab', () {
      expect(OrderSource.grab.backendValue, 'grab');
    });

    test('wongnai maps to wongnai', () {
      expect(OrderSource.wongnai.backendValue, 'wongnai');
    });
  });

  group('OrderSourceBackend — fromBackend', () {
    test('pos maps to dinein', () {
      expect(OrderSourceBackend.fromBackend('pos'), OrderSource.dinein);
    });

    test('grab maps to grab', () {
      expect(OrderSourceBackend.fromBackend('grab'), OrderSource.grab);
    });

    test('wongnai maps to wongnai', () {
      expect(OrderSourceBackend.fromBackend('wongnai'), OrderSource.wongnai);
    });

    test('unknown source falls back to dinein', () {
      expect(OrderSourceBackend.fromBackend('lineman'), OrderSource.dinein);
    });
  });

  // -------------------------------------------------------------------------
  // OrderStatus backend mapping
  // -------------------------------------------------------------------------
  group('OrderStatusBackend — toBackendValue', () {
    test('pending maps to pending', () {
      expect(OrderStatus.pending.backendValue, 'pending');
    });

    test('confirmed maps to accepted', () {
      expect(OrderStatus.confirmed.backendValue, 'accepted');
    });

    test('completed maps to ready', () {
      expect(OrderStatus.completed.backendValue, 'ready');
    });

    test('delivered maps to completed', () {
      expect(OrderStatus.delivered.backendValue, 'completed');
    });

    test('cancelled maps to cancelled', () {
      expect(OrderStatus.cancelled.backendValue, 'cancelled');
    });
  });

  group('OrderStatusBackend — fromBackend', () {
    test('pending → pending', () {
      expect(OrderStatusBackend.fromBackend('pending'), OrderStatus.pending);
    });

    test('accepted → confirmed', () {
      expect(OrderStatusBackend.fromBackend('accepted'), OrderStatus.confirmed);
    });

    test('preparing → confirmed (in-progress cooking)', () {
      expect(OrderStatusBackend.fromBackend('preparing'), OrderStatus.confirmed);
    });

    test('ready → completed (ready to serve)', () {
      expect(OrderStatusBackend.fromBackend('ready'), OrderStatus.completed);
    });

    test('completed → delivered (order handed off)', () {
      expect(OrderStatusBackend.fromBackend('completed'), OrderStatus.delivered);
    });

    test('cancelled → cancelled', () {
      expect(OrderStatusBackend.fromBackend('cancelled'), OrderStatus.cancelled);
    });

    test('unknown status falls back to pending', () {
      expect(OrderStatusBackend.fromBackend('unknown_value'), OrderStatus.pending);
    });
  });

  // -------------------------------------------------------------------------
  // OrderResponse normalization — handles both tRPC and DB field names
  // -------------------------------------------------------------------------
  group('OrderResponse.fromJson — field normalization', () {
    test('parses camelCase tRPC response (orderId, orderNumber, createdAt)', () {
      final r = OrderResponse.fromJson({
        'orderId': 'order-123',
        'orderNumber': 'ORD-20250216',
        'status': 'pending',
        'totalAmount': 99.50,
        'createdAt': '2025-02-16T10:00:00.000Z',
      });

      expect(r.orderId, 'order-123');
      expect(r.orderNumber, 'ORD-20250216');
      expect(r.status, 'pending');
      expect(r.totalAmount, 99.50);
    });

    test('parses DB snake_case response (id, order_number, created_at, total)', () {
      final r = OrderResponse.fromJson({
        'id': 'db-uuid-456',
        'order_number': 'ORD-20250216-B',
        'status': 'accepted',
        'total': 150.0,
        'created_at': '2025-02-16T11:00:00.000Z',
      });

      expect(r.orderId, 'db-uuid-456');
      expect(r.orderNumber, 'ORD-20250216-B');
      expect(r.status, 'accepted');
      expect(r.totalAmount, 150.0);
    });

    test('uses subtotal when total is absent', () {
      final r = OrderResponse.fromJson({
        'id': 'abc',
        'status': 'pending',
        'subtotal': 75.0,
        'created_at': '2025-02-16T12:00:00.000Z',
      });

      expect(r.totalAmount, 75.0);
    });

    test('orderId falls back to id field', () {
      final r = OrderResponse.fromJson({
        'id': 'fallback-id',
        'status': 'ready',
        'created_at': '2025-02-16T13:00:00.000Z',
      });

      expect(r.orderId, 'fallback-id');
    });

    test('orderNumber is nullable — absent field returns null', () {
      final r = OrderResponse.fromJson({
        'id': 'no-order-num',
        'status': 'pending',
        'created_at': '2025-02-16T14:00:00.000Z',
      });

      expect(r.orderNumber, isNull);
    });

    test('totalAmount defaults to 0.0 when absent', () {
      final r = OrderResponse.fromJson({
        'id': 'no-total',
        'status': 'pending',
        'created_at': '2025-02-16T15:00:00.000Z',
      });

      expect(r.totalAmount, 0.0);
    });
  });

  // -------------------------------------------------------------------------
  // OrderRequest source field uses backend enum value
  // -------------------------------------------------------------------------
  group('OrderRequest — source field uses backend enum value', () {
    test('source serializes to pos for dinein', () {
      const req = OrderRequest(
        tenantId: 'org-1',
        branchId: 'branch-1',
        source: 'pos', // After mapping dinein → pos
        items: [],
        totalAmount: 50.0,
        paymentMethod: 'cash',
      );

      final json = req.toJson();
      expect(json['source'], 'pos');
    });

    test('toJson round-trips correctly', () {
      const req = OrderRequest(
        tenantId: 'org-2',
        branchId: 'branch-2',
        source: 'grab',
        items: [],
        totalAmount: 120.0,
        paymentMethod: 'card',
        tableNumber: 'T5',
      );

      final json = req.toJson();
      final restored = OrderRequest.fromJson(json);

      expect(restored.tenantId, 'org-2');
      expect(restored.source, 'grab');
      expect(restored.totalAmount, 120.0);
      expect(restored.tableNumber, 'T5');
    });
  });
}
