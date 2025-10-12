import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_mobile/ui/screens/chat_screen.dart';

void main() {
  testWidgets('Chat input and send button present', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ChatScreen()));

    expect(find.text('Chat messages appear here'), findsOneWidget);
    final input = find.byType(TextField);
    expect(input, findsOneWidget);
    expect(find.byIcon(Icons.send), findsOneWidget);

    await tester.enterText(input, 'Hello');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    // No assertion on behavior (send is noop), just ensure no exceptions and UI present
  });
}