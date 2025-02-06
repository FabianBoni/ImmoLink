import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:immolink/main.dart';

void main() {
  testWidgets('Initial app test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: ImmoLink(),
      ),
    );

    // Verify that our app renders without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}