// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ringo_ringtones/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ringo_ringtones/data/repositories/ringtone_repository.dart';

void main() {
  testWidgets('Ringo App smoke test', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ringtoneRepositoryProvider.overrideWithValue(RingtoneRepository(prefs)),
        ],
        child: const RingoApp(),
      ),
    );

    // Verify that the app title and main sections are present
    expect(find.text('Ringo'), findsOneWidget); // AppBar title
    // Trigger a frame for animations
    await tester.pumpAndSettle();
    
    // Note: Trending text might be inside a carousel which needs time or specific finder
    // Checking for a basic UI element like the SearchBar or NavigationDestination
    expect(find.byIcon(Icons.search), findsOneWidget); 
    expect(find.byIcon(Icons.home), findsOneWidget);
  });
}
