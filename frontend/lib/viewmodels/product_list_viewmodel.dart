import 'package:flutter/foundation.dart';
import '../repositories/product_repository.dart';

class ProductListViewModel extends ChangeNotifier {
  final ProductRepository _repo;
  bool loading = false;
  List<dynamic> items = [];
  String? error;

  ProductListViewModel(this._repo);

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      items = await _repo.fetchProducts();
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }
}
