import 'package:flutter/foundation.dart';
import '../repositories/product_repository.dart';

class ProductListViewModel extends ChangeNotifier {
  final ProductRepository _repo;
  bool loading = false;
  List<dynamic> items = [];
  String? error;
  Map<String, dynamic> filters = {};
  int _currentPage = 1;
  int _pageSize = 10;
  bool _hasMore = true;
  bool _loadingMore = false;

  ProductListViewModel(this._repo);

  Future<void> load({Map<String, dynamic>? filters}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      if (filters != null) this.filters = filters;
      // reset pagination
      _currentPage = this.filters['PageNumber'] is int ? this.filters['PageNumber'] as int : 1;
      _pageSize = this.filters['PageSize'] is int ? this.filters['PageSize'] as int : 10;
      this.filters['PageNumber'] = _currentPage;
      this.filters['PageSize'] = _pageSize;
      items = await _repo.fetchProducts(query: this.filters.isNotEmpty ? this.filters : null);
      _hasMore = (items.length >= _pageSize);
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  /// Load next page and append to items. No-op if already loading or no more items.
  Future<void> loadMore() async {
    if (_loadingMore || !_hasMore) return;
    _loadingMore = true;
    try {
      _currentPage += 1;
      filters['PageNumber'] = _currentPage;
      filters['PageSize'] = _pageSize;
      final next = await _repo.fetchProducts(query: filters.isNotEmpty ? filters : null);
      if (next.isNotEmpty) {
        items.addAll(next);
        _hasMore = next.length >= _pageSize;
      } else {
        _hasMore = false;
      }
      notifyListeners();
    } catch (_) {
      // ignore loadMore errors for now
    }
    _loadingMore = false;
  }

  void updateFilters(Map<String, dynamic> newFilters) {
    filters = {...filters, ...newFilters};
    load(filters: filters);
  }
}
