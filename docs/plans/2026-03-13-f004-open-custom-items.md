# F-004: Open / Custom Price Items — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Let cashiers add items not on the menu (e.g., "Special Plate", "Extra Charge") with a custom name and price.

**Architecture:** Use a synthetic `MenuItem.custom()` factory so custom items flow through the exact same cart → checkout → sync pipeline as regular items. The API's `menuItemId` becomes optional (DB already supports null). A new `OpenItemDialog` widget collects name + price, creates the synthetic MenuItem, and adds it to the cart.

**Tech Stack:** Flutter/Dart (Riverpod, Freezed, Google Fonts), tRPC (Zod), Drizzle ORM

---

### Task 1: Make menuItemId optional in API + mark custom items

**Files:**
- Modify: `apps/api/routers/order.ts:54-55` (Zod schema)
- Modify: `apps/api/routers/order.ts:130` (insert — already handles null)
- Test: `apps/api/routers/order.test.ts`

**Step 1: Update Zod orderItemSchema**

In `apps/api/routers/order.ts`, change:
```typescript
const orderItemSchema = z.object({
  menuItemId: z.string().optional(),  // was z.string() — now nullable for custom items
  name: z.string(),
  quantity: z.number().int().positive(),
  price: z.string(),
  notes: z.string().optional(),
  modifiers: z.array(orderItemModifierSchema).optional(),
});
```

**Step 2: Update orderItem insert to handle null menuItemId**

In the insert loop (~line 130), change:
```typescript
menuItemId: item.menuItemId ?? null,
```

**Step 3: Run existing tests**

Run: `cd ~/Desktop/NexusPoint/NexusPoint\(web\) && bun api:test`
Expected: All 34 tests pass (existing behavior unaffected)

**Step 4: Add test for custom item order creation**

In `apps/api/routers/order.test.ts`, add a test that creates an order with `menuItemId: undefined` (omitted) and verifies it succeeds:

```typescript
it("creates order with custom (no menuItemId) item", async () => {
  const result = await caller.order.create({
    source: "pos",
    items: [{ name: "Special Plate", quantity: 1, price: "99.00" }],
    subtotal: "99.00",
    total: "99.00",
  });
  expect(result.id).toBeDefined();
});
```

Run: `cd ~/Desktop/NexusPoint/NexusPoint\(web\) && bun api:test`
Expected: All tests pass including new one

---

### Task 2: Add MenuItem.custom() factory

**Files:**
- Modify: `lib/core/models/menu_item.dart:13-31`
- Test: `test/unit/open_item_test.dart` (create new)

**Step 1: Write failing test**

Create `test/unit/open_item_test.dart`:
```dart
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
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd ~/Desktop/NexusPoint/NexusPoint-mobile && flutter test test/unit/open_item_test.dart`
Expected: FAIL — `MenuItem.custom` not defined

**Step 3: Implement MenuItem.custom() factory + isCustomItem getter**

In `lib/core/models/menu_item.dart`, add after line 27 (before the fromJson factory):

```dart
  const MenuItem._();

  bool get isCustomItem => id.startsWith('custom_');

  static MenuItem custom({required String name, required double price}) {
    if (name.trim().isEmpty) {
      throw ArgumentError('Custom item name must not be empty');
    }
    if (price <= 0) {
      throw ArgumentError('Custom item price must be positive');
    }
    return MenuItem(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      sku: 'CUSTOM',
      name: name.trim(),
      price: price,
      category: 'Open Item',
      isAvailable: true,
    );
  }
```

Note: Because MenuItem is a Freezed class, we need to add `const MenuItem._();` for the private constructor to enable the getter. This is the standard Freezed pattern for adding methods.

**Step 4: Regenerate Freezed code**

Run: `cd ~/Desktop/NexusPoint/NexusPoint-mobile && dart run build_runner build --delete-conflicting-outputs`

**Step 5: Run test to verify it passes**

Run: `cd ~/Desktop/NexusPoint/NexusPoint-mobile && flutter test test/unit/open_item_test.dart`
Expected: All 5 tests PASS

---

### Task 3: Create OpenItemDialog widget

**Files:**
- Create: `lib/features/register/widgets/open_item_dialog.dart`
- Test: `test/widget/open_item_dialog_test.dart` (create new)

**Step 1: Create the dialog**

Create `lib/features/register/widgets/open_item_dialog.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/pos_theme.dart';
import '../../../core/models/menu_item.dart';

/// Dialog for entering a custom/open price item.
/// Returns a [MenuItem] via Navigator.pop on confirm, or null on cancel.
class OpenItemDialog extends StatefulWidget {
  const OpenItemDialog({super.key});

  @override
  State<OpenItemDialog> createState() => _OpenItemDialogState();
}

class _OpenItemDialogState extends State<OpenItemDialog> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: PosTheme.accentAmber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.edit_note_rounded,
                        color: PosTheme.accentAmber,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Open Item',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Name field
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Item Name',
                    hintText: 'e.g. Special Plate',
                    prefixIcon: Icon(Icons.label_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an item name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Price field
                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Price (THB)',
                    hintText: '0.00',
                    prefixIcon: Icon(Icons.payments_outlined),
                    prefixText: '฿ ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final price = double.tryParse(value ?? '');
                    if (price == null || price <= 0) {
                      return 'Enter a valid price greater than 0';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _onConfirm,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: PosTheme.accentAmber,
                        ),
                        child: const Text('Add to Cart'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onConfirm() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final price = double.parse(_priceController.text);

    final customItem = MenuItem.custom(name: name, price: price);
    Navigator.of(context).pop(customItem);
  }
}

/// Show the open item dialog and return the created MenuItem, or null.
Future<MenuItem?> showOpenItemDialog(BuildContext context) {
  return showDialog<MenuItem>(
    context: context,
    builder: (_) => const OpenItemDialog(),
  );
}
```

**Step 2: Write widget test**

Create `test/widget/open_item_dialog_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexuspoint_pos/features/register/widgets/open_item_dialog.dart';

void main() {
  group('OpenItemDialog', () {
    testWidgets('validates empty name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: OpenItemDialog())),
      );
      await tester.tap(find.text('Add to Cart'));
      await tester.pump();
      expect(find.text('Please enter an item name'), findsOneWidget);
    });

    testWidgets('validates zero price', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: OpenItemDialog())),
      );
      await tester.enterText(find.byType(TextFormField).first, 'Test Item');
      await tester.enterText(find.byType(TextFormField).last, '0');
      await tester.tap(find.text('Add to Cart'));
      await tester.pump();
      expect(find.text('Enter a valid price greater than 0'), findsOneWidget);
    });

    testWidgets('cancel returns null', (tester) async {
      MenuItem? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showOpenItemDialog(context);
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(result, isNull);
    });
  });
}
```

**Step 3: Run tests**

Run: `cd ~/Desktop/NexusPoint/NexusPoint-mobile && flutter test test/widget/open_item_dialog_test.dart`
Expected: All 3 tests PASS

---

### Task 4: Add "Open Item" button to Speed Register

**Files:**
- Modify: `lib/features/register/widgets/speed_register_screen.dart:18-29` (AppBar actions)

**Step 1: Add import and Open Item button to AppBar**

In `speed_register_screen.dart`, add import at top:
```dart
import 'open_item_dialog.dart';
import '../../../core/models/menu_item.dart';
```

Update the AppBar actions (line 20-29) to include an "Open Item" button before the refresh button:

```dart
appBar: AppBar(
  title: const Text('Speed Register'),
  actions: [
    // Open Item button
    FilledButton.tonalIcon(
      onPressed: () async {
        final customItem = await showOpenItemDialog(context);
        if (customItem != null) {
          ref.read(cartProvider.notifier).addItem(customItem);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Added "${customItem.name}" to cart'),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
                width: 300,
              ),
            );
          }
        }
      },
      icon: const Icon(Icons.edit_note_rounded, size: 20),
      label: const Text('Open Item'),
    ),
    const SizedBox(width: 8),
    IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: () {
        ref.invalidate(menuProvider);
      },
      tooltip: 'Refresh Menu',
    ),
    const SizedBox(width: 8),
  ],
),
```

**Step 2: Run full test suite**

Run: `cd ~/Desktop/NexusPoint/NexusPoint-mobile && flutter test`
Expected: All tests pass (no regressions)

---

### Task 5: Send null menuItemId for custom items in sync payload

**Files:**
- Modify: `lib/core/models/api_models.dart:84-104` (BackendOrderItemDto)
- Modify: `test/unit/order_sync_payload_test.dart`

**Step 1: Update BackendOrderItemDto.fromOrderItemDto to handle custom items**

In `api_models.dart`, update the `fromOrderItemDto` static method (~line 97):

```dart
  static BackendOrderItemDto fromOrderItemDto(OrderItemDto dto) {
    final isCustom = dto.skuId.startsWith('custom_');
    return BackendOrderItemDto(
      menuItemId: isCustom ? '' : dto.skuId,
      name: dto.name ?? dto.skuId,
      quantity: dto.quantity,
      price: dto.unitPrice.toStringAsFixed(2),
      notes: dto.notes,
    );
  }
```

Also update `toJsonWithModifiers` (~line 108):

```dart
  static Map<String, dynamic> toJsonWithModifiers(
    OrderItemDto dto,
    List<SelectedModifierOption> modifiers,
  ) {
    final isCustom = dto.skuId.startsWith('custom_');
    return {
      if (!isCustom) 'menuItemId': dto.skuId,
      'name': dto.name ?? dto.skuId,
      'quantity': dto.quantity,
      'price': dto.unitPrice.toStringAsFixed(2),
      if (dto.notes != null) 'notes': dto.notes,
      if (modifiers.isNotEmpty)
        'modifiers': modifiers
            .map((m) => {
                  'modifierOptionId': m.optionId,
                  'name': m.name,
                  'priceAdjustment': m.priceAdjustment.toStringAsFixed(2),
                })
            .toList(),
    };
  }
```

**Step 2: Add sync payload test for custom items**

In `test/unit/order_sync_payload_test.dart`, add to the F-003 group:

```dart
test('custom item omits menuItemId from payload', () {
  final dto = OrderItemDto(
    skuId: 'custom_1234567890',
    name: 'Special Plate',
    quantity: 1,
    unitPrice: 99.0,
  );

  final backend = BackendOrderItemDto.fromOrderItemDto(dto);
  expect(backend.menuItemId, '');
  expect(backend.name, 'Special Plate');
});
```

**Step 3: Run tests**

Run: `cd ~/Desktop/NexusPoint/NexusPoint-mobile && flutter test test/unit/order_sync_payload_test.dart`
Expected: All tests pass

---

### Task 6: Web — tag custom items in live-orders view

**Files:**
- Modify: `apps/app/routes/(app)/live-orders.tsx:72-96` (order card rendering)

**Step 1: Add "Open Item" indicator in order card**

In the order card section of `live-orders.tsx`, after the customer name display, add a check for custom items:

The items are stored in the order's JSONB `items` field. In the card, after `{order.customerName && ...}`, add:

```tsx
{Array.isArray(order.items) && order.items.some((i: { menuItemId?: string }) => !i.menuItemId) && (
  <span className="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-purple-100 text-purple-800">
    Has Open Items
  </span>
)}
```

**Step 2: Verify web typecheck**

Run: `cd ~/Desktop/NexusPoint/NexusPoint\(web\) && bun --filter @repo/api build && bunx --bun tsc --noEmit -p apps/app/tsconfig.json 2>&1 | grep -E "live-orders|error" | head -10`
Expected: No errors in live-orders.tsx

---

### Task 7: Update SPEC-KIT + final verification

**Files:**
- Modify: `~/Desktop/NexusPoint/.specify/SPEC-KIT-NEXUSPOINT.md` (F-004 section)

**Step 1: Run full Flutter test suite**

Run: `cd ~/Desktop/NexusPoint/NexusPoint-mobile && flutter test`
Expected: All tests pass (207+ tests)

**Step 2: Run flutter analyze**

Run: `cd ~/Desktop/NexusPoint/NexusPoint-mobile && flutter analyze`
Expected: No errors

**Step 3: Run API tests**

Run: `cd ~/Desktop/NexusPoint/NexusPoint\(web\) && bun api:test`
Expected: All tests pass (35+ tests)

**Step 4: Update SPEC-KIT**

Update F-004 section in `SPEC-KIT-NEXUSPOINT.md`:
- Change status to `[x] COMPLETE`
- Fill in "What was built" checklist
- Update progress summary counts
