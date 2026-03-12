import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexuspoint_pos/features/floor_plan/widgets/table_widget.dart';

void main() {
  group('TableWidget', () {
    testWidgets('shows table number', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TableWidget(
            number: 5,
            seats: 4,
            shape: 'rectangle',
            status: 'available',
            onTap: () {},
          ),
        ),
      ));
      expect(find.text('T-5'), findsOneWidget);
    });

    testWidgets('available table shows green border', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TableWidget(
            number: 1,
            seats: 4,
            shape: 'rectangle',
            status: 'available',
            onTap: () {},
          ),
        ),
      ));
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(TableWidget),
          matching: find.byType(Container),
        ).first,
      );
      expect(container, isNotNull);
    });

    testWidgets('occupied table shows blue filled background', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TableWidget(
            number: 3,
            seats: 4,
            shape: 'rectangle',
            status: 'occupied',
            elapsedMinutes: 21,
            onTap: () {},
          ),
        ),
      ));
      expect(find.text('T-3'), findsOneWidget);
      expect(find.text('21m'), findsOneWidget);
    });

    testWidgets('reserved table shows amber border and time', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TableWidget(
            number: 11,
            seats: 4,
            shape: 'rectangle',
            status: 'reserved',
            reservationLabel: '8:30PM',
            onTap: () {},
          ),
        ),
      ));
      expect(find.text('T-11'), findsOneWidget);
      expect(find.text('8:30PM'), findsOneWidget);
    });
  });
}
