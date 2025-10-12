import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_mobile/ui/screens/home_screen.dart';

void main() {
  testWidgets('Home buttons navigate to respective screens', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: const HomeScreen(),
      routes: {
  '/products': (c) => Scaffold(appBar: AppBar(title: const Text('Products Page')), body: const Center(child: Text('Products Page'))),
  '/cart': (c) => Scaffold(appBar: AppBar(title: const Text('Cart Page')), body: const Center(child: Text('Cart Page'))),
  '/map': (c) => Scaffold(appBar: AppBar(title: const Text('Map Page')), body: const Center(child: Text('Map Page'))),
  '/chat': (c) => Scaffold(appBar: AppBar(title: const Text('Chat Page')), body: const Center(child: Text('Chat Page'))),
      },
    ));

    // Products
    expect(find.text('Products'), findsOneWidget);
  await tester.tap(find.text('Products'));
  await tester.pumpAndSettle();
  // AppBar and body both contain the same text; ensure at least one instance is present
  expect(find.text('Products Page'), findsWidgets);

    // Back to home
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Cart
  await tester.tap(find.text('Cart'));
  await tester.pumpAndSettle();
  expect(find.text('Cart Page'), findsWidgets);

    await tester.pageBack();
    await tester.pumpAndSettle();

    // Map
  await tester.tap(find.text('Map'));
  await tester.pumpAndSettle();
  expect(find.text('Map Page'), findsWidgets);

    await tester.pageBack();
    await tester.pumpAndSettle();

    // Chat
  await tester.tap(find.text('Chat'));
  await tester.pumpAndSettle();
  expect(find.text('Chat Page'), findsWidgets);
  });
}
