import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homework_tracker/widgets/add_fab.dart';

void main() {
  testWidgets('AddFAB renders and triggers onPressed when tapped', (
    WidgetTester tester,
  ) async {
    bool wasPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          floatingActionButton: AddFAB(
            onPressed: () {
              wasPressed = true;
            },
          ),
        ),
      ),
    );

    // Verify that the FAB is present
    expect(find.byIcon(Icons.add), findsOneWidget);

    // Tap the FAB
    await tester.tap(find.byType(AddFAB));
    await tester.pump();

    // Verify that the onPressed callback was triggered
    expect(wasPressed, isTrue);
  });
}