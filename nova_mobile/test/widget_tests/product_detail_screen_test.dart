import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_mobile/ui/screens/product_detail_screen.dart';

void main() {
  testWidgets('Product detail displays id from route arguments', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (ctx) {
        return ElevatedButton(
            onPressed: () => Navigator.pushNamed(ctx, '/product', arguments: {'id': 42}),
            child: const Text('Go'));
      }),
      routes: {'/product': (c) => const ProductDetailScreen()},
    ));

    expect(find.text('Go'), findsOneWidget);
    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();

    expect(find.text('Product #42'), findsOneWidget);
    expect(find.text('Add to cart'), findsOneWidget);
  });
}
