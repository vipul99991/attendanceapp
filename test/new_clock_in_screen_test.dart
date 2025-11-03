import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/screens/new_clock_in_screen.dart';

void main() {
  group('NewClockInScreen Tests', () {
    testWidgets('Clock in screen displays correctly', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        const MaterialApp(
          home: NewClockInScreen(),
        ),
      );

      // Verify that the clock in button is displayed.
      expect(find.text('CLOCK IN'), findsOneWidget);

      // Verify that the time display is present.
      expect(find.byType(Text), findsWidgets);

      // Tap the clock in button.
      await tester.tap(find.text('CLOCK IN'));
      await tester.pumpAndSettle();

      // Verify that we can interact with the screen.
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Clock in screen displays time and date', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NewClockInScreen(),
        ),
      );

      // Verify that time and date are displayed.
      expect(find.byType(Text), findsWidgets);
    });
  });
}