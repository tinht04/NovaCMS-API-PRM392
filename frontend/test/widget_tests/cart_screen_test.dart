import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_mobile/ui/screens/cart_screen.dart';

void main() {
  testWidgets('Cart checkout navigates to payment', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: const CartScreen(),
      routes: {'/payment': (c) => const Scaffold(body: Center(child: Text('PaymentPage')))},
    ));

    expect(find.text('Your cart is empty'), findsOneWidget);
    await tester.tap(find.text('Checkout'));
    await tester.pumpAndSettle();

    expect(find.text('PaymentPage'), findsOneWidget);
  });
}
