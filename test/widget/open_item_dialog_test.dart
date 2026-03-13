import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexuspoint_pos/core/models/menu_item.dart';
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
