// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:study_aid/main.dart';

import 'package:study_aid/features/authentication/presentation/providers/user_providers.dart';

void main() {
  testWidgets('App startup smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(ProviderScope(
      overrides: [
        userProvider.overrideWith((ref) async => null),
        userBoxProvider.overrideWith((ref) async => throw UnimplementedError()),
      ],
      child: const MyApp(),
    ));

    // Verify that the splash screen is shown
    expect(find.byType(FadeTransition), findsOneWidget);
  });
}
