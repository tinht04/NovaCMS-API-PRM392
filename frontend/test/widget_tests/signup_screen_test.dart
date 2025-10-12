import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_mobile/ui/screens/signup_screen.dart';

void main() {
  testWidgets('Signup form fields and register button', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignupScreen()));

    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.text('Register'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'John Doe');
    await tester.enterText(find.byType(TextField).at(1), 'john@example.com');
    await tester.enterText(find.byType(TextField).at(2), 'secret');

    // Press register - button is no-op but should not throw
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
  });
}
