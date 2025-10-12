import 'package:flutter_test/flutter_test.dart';
import 'package:nova_mobile/viewmodels/product_list_viewmodel.dart';
import '../fakes/fake_product_repository.dart';

void main() {
  group('ProductListViewModel', () {
    test('loads items successfully', () async {
      final repo = FakeProductRepository(() => [
            {'equipmentId': 1, 'equipmentName': 'A'},
            {'equipmentId': 2, 'equipmentName': 'B'}
          ]);
      final vm = ProductListViewModel(repo);

      await vm.load();
      expect(vm.loading, isFalse);
      expect(vm.items.length, 2);
      expect(vm.error, isNull);
    });

    test('empty list handled', () async {
      final repo = FakeProductRepository(() => <Map<String, dynamic>>[]);
      final vm = ProductListViewModel(repo);

      await vm.load();
      expect(vm.items, isEmpty);
      expect(vm.error, isNull);
    });

    test('propagates exception into error', () async {
      final repo = FakeProductRepository(() => throw Exception('fail'));
      final vm = ProductListViewModel(repo);

      await vm.load();
      expect(vm.items, isEmpty);
      expect(vm.error, contains('fail'));
    });
  });
}
