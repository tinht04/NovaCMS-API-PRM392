import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_mobile/ui/screens/product_list_screen.dart';
import 'package:nova_mobile/viewmodels/product_list_viewmodel.dart';
import 'package:nova_mobile/repositories/product_repository.dart';

import 'package:nova_mobile/core/network/api_client.dart';

class FakeProductRepository extends ProductRepository {
  FakeProductRepository(List<Map<String, dynamic>> items)
      : _items = items,
        super(apiClient: ApiClient());

  final List<Map<String, dynamic>> _items;

  @override
  Future<List<Map<String, dynamic>>> fetchProducts({Map<String, dynamic>? query}) async {
    return _items;
  }
}

void main() {
  testWidgets('Product list shows items and navigates to detail', (tester) async {
    final fakeRepo = FakeProductRepository([
      {'equipmentId': 1, 'equipmentName': 'Drill', 'imageUrl': null},
      {'equipmentId': 2, 'equipmentName': 'Saw', 'imageUrl': null},
    ]);
    final vm = ProductListViewModel(fakeRepo);

    await tester.pumpWidget(MaterialApp(
      home: ProductListScreen(viewModel: vm),
      routes: {'/product': (c) => const Scaffold(body: Text('Product Detail'))},
    ));

    // allow VM.load to run
    await tester.pumpAndSettle();

    expect(find.text('Drill'), findsOneWidget);
    expect(find.text('Saw'), findsOneWidget);

    await tester.tap(find.text('Drill'));
    await tester.pumpAndSettle();

    expect(find.text('Product Detail'), findsOneWidget);
  });
}
