import 'dart:async';

import 'package:nova_mobile/repositories/product_repository.dart';
import 'package:nova_mobile/core/network/api_client.dart';

class FakeProductRepository extends ProductRepository {
  FakeProductRepository(FutureOr<List<Map<String, dynamic>>> Function() handler)
      : _handler = handler,
        // provide a real ApiClient for the base class; it won't be used in tests
        super(apiClient: ApiClient());

  final FutureOr<List<Map<String, dynamic>>> Function() _handler;

  @override
  Future<List<Map<String, dynamic>>> fetchProducts({Map<String, dynamic>? query}) async {
    final res = _handler();
    if (res is Future<List<Map<String, dynamic>>>) return await res;
    return res;
  }
}
