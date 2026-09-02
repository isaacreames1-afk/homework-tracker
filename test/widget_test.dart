
import 'package:flutter_test/flutter_test.dart';
import 'package:homework_tracker/main.dart';

void main() {
  testWidgets('Homework Tracker app starts with splash screen',
      (WidgetTester tester) async {
    // Build the app.
    await tester.pumpWidget(const HomeworkTrackerApp());

    // Verify that the splash screen displays the app title.
    expect(find.text('Homework Tracker'), findsOneWidget);
  });
}

