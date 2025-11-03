import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:attendanceapp/main.dart';
import 'package:attendanceapp/services/theme_manager.dart';

void main() {
  group('App Navigation', () {
    late ThemeManager themeManager;

    setUp(() {
      themeManager = ThemeManager();
    });

    testWidgets('app launches and shows splash screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeManager>.value(
          value: themeManager,
          child: const AttendanceApp(),
        ),
      );

      // Initially should show splash screen
      expect(find.text('AttendanceApp'), findsOneWidget);
      
      // Wait for splash screen to transition
      await tester.pumpAndSettle();
    });
  });
}