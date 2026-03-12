import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('TableActionSheet', () {
    testWidgets('available table shows New Dine-In Order button', (tester) async {
      // Render sheet with available table
      // Expect 'New Dine-In Order' button
    });

    testWidgets('occupied table shows Open Order button', (tester) async {
      // Render sheet with occupied table
      // Expect 'Open Order' button and elapsed time
    });

    testWidgets('reserved table shows Seat Guests button', (tester) async {
      // Render sheet with reserved table
      // Expect 'Seat Guests' button and reservation info
    });

    testWidgets('guest count stepper min is 1 max is seat count', (tester) async {
      // Render available table with 4 seats
      // Try to go below 1 — button should be disabled
      // Try to go above 4 — button should be disabled
    });
  });
}
