import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nexuspoint_pos/core/models/cart_item.dart';
import 'package:nexuspoint_pos/core/models/menu_item.dart';
import 'package:nexuspoint_pos/features/cart/providers/cart_provider.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _fishChip = MenuItem(
  id: 'item-1',
  sku: 'F001',
  organizationId: 'org-1',
  name: 'Fish & Chip',
  price: 100.0,
);

SelectedModifierOption _option({
  String optionId = 'opt-large',
  String groupId = 'grp-size',
  String groupName = 'Size',
  String name = 'Large',
  double priceAdjustment = 20.0,
}) =>
    SelectedModifierOption(
      optionId: optionId,
      groupId: groupId,
      groupName: groupName,
      name: name,
      priceAdjustment: priceAdjustment,
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // SelectedModifierOption — model & serialization
  // -------------------------------------------------------------------------
  group('SelectedModifierOption', () {
    test('constructs correctly', () {
      final opt = _option();
      expect(opt.optionId, 'opt-large');
      expect(opt.groupId, 'grp-size');
      expect(opt.groupName, 'Size');
      expect(opt.name, 'Large');
      expect(opt.priceAdjustment, 20.0);
    });

    test('toJson / fromJson round-trip', () {
      final opt = _option();
      final json = opt.toJson();

      expect(json['optionId'], 'opt-large');
      expect(json['groupId'], 'grp-size');
      expect(json['groupName'], 'Size');
      expect(json['name'], 'Large');
      expect(json['priceAdjustment'], 20.0);

      final restored = SelectedModifierOption.fromJson(json);
      expect(restored.optionId, opt.optionId);
      expect(restored.name, opt.name);
      expect(restored.priceAdjustment, opt.priceAdjustment);
    });

    test('fromJson handles missing priceAdjustment (defaults to 0)', () {
      final opt = SelectedModifierOption.fromJson({
        'optionId': 'opt-small',
        'groupId': 'grp-size',
        'groupName': 'Size',
        'name': 'Small',
      });
      expect(opt.priceAdjustment, 0.0);
    });

    test('toJson serialises to JSON string without error', () {
      final opt = _option();
      expect(() => jsonEncode(opt.toJson()), returnsNormally);
    });
  });

  // -------------------------------------------------------------------------
  // CartItem with modifiers
  // -------------------------------------------------------------------------
  group('CartItem with modifiers', () {
    test('modifierTotal sums priceAdjustments', () {
      final item = CartItem(
        menuItem: _fishChip,
        quantity: 1,
        unitPrice: 100.0,
        selectedModifiers: [
          _option(priceAdjustment: 20.0),
          _option(optionId: 'opt-extra', name: 'Extra Sauce', priceAdjustment: 10.0),
        ],
      );

      expect(item.modifierTotal, 30.0);
    });

    test('lineTotal = (unitPrice + modifierTotal) * quantity', () {
      final item = CartItem(
        menuItem: _fishChip,
        quantity: 2,
        unitPrice: 100.0,
        selectedModifiers: [_option(priceAdjustment: 20.0)],
      );

      expect(item.lineTotal, 240.0); // (100 + 20) * 2
    });

    test('lineTotal with no modifiers equals unitPrice * quantity', () {
      final item = CartItem(
        menuItem: _fishChip,
        quantity: 3,
        unitPrice: 100.0,
      );

      expect(item.lineTotal, 300.0);
    });

    test('selectedModifiers defaults to empty list', () {
      final item = CartItem(
        menuItem: _fishChip,
        quantity: 1,
        unitPrice: 100.0,
      );

      expect(item.selectedModifiers, isEmpty);
      expect(item.modifierTotal, 0.0);
    });

    test('toJson selectedModifiers serialises as List of maps', () {
      final item = CartItem(
        menuItem: _fishChip,
        quantity: 1,
        unitPrice: 100.0,
        selectedModifiers: [_option()],
      );

      final json = item.toJson();
      // _modifiersToJson should produce List<Map>, not List<SelectedModifierOption>
      final rawModifiers = json['selectedModifiers'] as List;
      expect(rawModifiers.first, isA<Map<String, dynamic>>());
      expect(rawModifiers.first['name'], 'Large');
    });

    test('jsonEncode + fromJson round-trip preserves modifiers', () {
      final item = CartItem(
        menuItem: _fishChip,
        quantity: 1,
        unitPrice: 100.0,
        selectedModifiers: [_option()],
      );

      // Simulate storage: encode to string then decode back to map
      final encoded = jsonEncode(item.toJson());
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;

      final modifiers = decoded['selectedModifiers'] as List;
      expect(modifiers.first['name'], 'Large');

      final restored = CartItem.fromJson(decoded);
      expect(restored.selectedModifiers.length, 1);
      expect(restored.selectedModifiers.first.name, 'Large');
      expect(restored.selectedModifiers.first.priceAdjustment, 20.0);
    });
  });

  // -------------------------------------------------------------------------
  // CartNotifier with modifiers
  // -------------------------------------------------------------------------
  group('CartNotifier with modifiers', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('adds item with modifiers to cart', () {
      container.read(cartProvider.notifier).addItem(
        _fishChip,
        selectedModifiers: [_option()],
      );

      final cart = container.read(cartProvider);
      expect(cart.items.length, 1);
      expect(cart.items.first.selectedModifiers.length, 1);
      expect(cart.items.first.selectedModifiers.first.name, 'Large');
    });

    test('same item with SAME modifiers increments quantity', () {
      container.read(cartProvider.notifier).addItem(
        _fishChip,
        selectedModifiers: [_option()],
      );
      container.read(cartProvider.notifier).addItem(
        _fishChip,
        selectedModifiers: [_option()],
      );

      final cart = container.read(cartProvider);
      expect(cart.items.length, 1);
      expect(cart.items.first.quantity, 2);
    });

    test('same item with DIFFERENT modifiers creates separate line items', () {
      container.read(cartProvider.notifier).addItem(
        _fishChip,
        selectedModifiers: [_option(optionId: 'opt-small', name: 'Small', priceAdjustment: 0)],
      );
      container.read(cartProvider.notifier).addItem(
        _fishChip,
        selectedModifiers: [_option(optionId: 'opt-large', name: 'Large', priceAdjustment: 20)],
      );

      final cart = container.read(cartProvider);
      expect(cart.items.length, 2);
    });

    test('item without modifiers and same item WITH modifiers are separate', () {
      container.read(cartProvider.notifier).addItem(_fishChip);
      container.read(cartProvider.notifier).addItem(
        _fishChip,
        selectedModifiers: [_option()],
      );

      final cart = container.read(cartProvider);
      expect(cart.items.length, 2);
    });

    test('subtotal includes modifier price adjustments', () {
      // ฿100 base + ฿20 Large modifier
      container.read(cartProvider.notifier).addItem(
        _fishChip,
        selectedModifiers: [_option(priceAdjustment: 20.0)],
      );

      final cart = container.read(cartProvider);
      // lineTotal = (100 + 20) * 1 = 120
      expect(cart.subtotal, 120.0);
    });

    test('total includes 7% VAT on modifier-adjusted subtotal', () {
      container.read(cartProvider.notifier).addItem(
        _fishChip,
        selectedModifiers: [_option(priceAdjustment: 20.0)],
      );

      final cart = container.read(cartProvider);
      expect(cart.subtotal, 120.0);
      expect(cart.tax, closeTo(8.4, 0.01)); // 7% of 120
      expect(cart.total, closeTo(128.4, 0.01));
    });

    test('removeItem removes correct line when multiple modifier variants', () {
      container.read(cartProvider.notifier).addItem(
        _fishChip,
        selectedModifiers: [_option(optionId: 'opt-small', name: 'Small', priceAdjustment: 0)],
      );
      container.read(cartProvider.notifier).addItem(
        _fishChip,
        selectedModifiers: [_option(optionId: 'opt-large', name: 'Large', priceAdjustment: 20)],
      );

      container.read(cartProvider.notifier).removeItem(0);

      final cart = container.read(cartProvider);
      expect(cart.items.length, 1);
      expect(cart.items.first.selectedModifiers.first.name, 'Large');
    });

    test('clear resets cart with modifiers', () {
      container.read(cartProvider.notifier).addItem(
        _fishChip,
        selectedModifiers: [_option()],
      );
      container.read(cartProvider.notifier).clear();

      final cart = container.read(cartProvider);
      expect(cart.items, isEmpty);
      expect(cart.total, 0.0);
    });
  });

  // -------------------------------------------------------------------------
  // Modifier summary for order notes
  // -------------------------------------------------------------------------
  group('Modifier summary encoding', () {
    test('modifier names join correctly for single group', () {
      final modifiers = [_option(groupName: 'Size', name: 'Large')];
      final summary = modifiers.map((m) => '${m.groupName}: ${m.name}').join(', ');
      expect(summary, 'Size: Large');
    });

    test('multiple modifier groups join with comma', () {
      final modifiers = [
        _option(groupName: 'Size', name: 'Large'),
        _option(
          optionId: 'opt-spicy',
          groupId: 'grp-spice',
          groupName: 'Spice',
          name: 'Medium Hot',
          priceAdjustment: 0,
        ),
      ];
      final summary = modifiers.map((m) => '${m.groupName}: ${m.name}').join(', ');
      expect(summary, 'Size: Large, Spice: Medium Hot');
    });

    test('empty modifiers produce empty summary', () {
      final modifiers = <SelectedModifierOption>[];
      final summary = modifiers.map((m) => '${m.groupName}: ${m.name}').join(', ');
      expect(summary, isEmpty);
    });
  });
}
