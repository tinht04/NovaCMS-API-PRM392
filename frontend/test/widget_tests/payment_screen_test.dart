import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_mobile/ui/screens/payment_screen.dart';

void main() {
  testWidgets('Payment screen shows pay button and accepts tap', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PaymentScreen()));

    expect(find.text('Payment flow placeholder'), findsOneWidget);
    expect(find.text('Pay'), findsOneWidget);

    await tester.tap(find.text('Pay'));
    await tester.pumpAndSettle();
  });
}