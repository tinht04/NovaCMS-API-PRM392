import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_mobile/ui/screens/payment_screen.dart';

void main() {
  testWidgets('Payment screen shows pay button and accepts tap', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PaymentScreen()));

  // Only verify Pay button exists and can be tapped (we don't perform real network calls in this widget test)
  expect(find.text('Pay'), findsOneWidget);
  await tester.tap(find.text('Pay'));
  await tester.pumpAndSettle();
  });
}