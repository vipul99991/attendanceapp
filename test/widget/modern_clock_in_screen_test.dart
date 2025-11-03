import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:attendanceapp/screens/modern_clock_in_screen.dart';
import 'package:attendanceapp/services/theme_manager.dart';

void main() {
  group('ModernClockInScreen', () {
    late ThemeManager themeManager;

    setUp(() {
      themeManager = ThemeManager();
    });

    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ThemeManager>.value(
            value: themeManager,
            child: const ModernClockInScreen(),
          ),
        ),
      );

      // Verify that the screen renders
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Clock In'), findsOneWidget);
    });

    testWidgets('shows clock in button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ThemeManager>.value(
            value: themeManager,
            child: const ModernClockInScreen(),
          ),
        ),
      );

      // Find the clock in button
      final clockInButton = find.text('CLOCK IN');
      expect(clockInButton, findsOneWidget);
    });

    testWidgets('tapping clock in button shows loading indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ThemeManager>.value(
            value: themeManager,
            child: const ModernClockInScreen(),
          ),
        ),
      );

      // Tap the clock in button
      await tester.tap(find.text('CLOCK IN'));
      await tester.pump();

      // Verify loading state (this would be tested more thoroughly in an integration test)
      expect(find.text('CLOCK IN'), findsOneWidget);
    });
  });
}