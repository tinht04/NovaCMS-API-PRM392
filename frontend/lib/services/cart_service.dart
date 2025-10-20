import 'package:flutter/foundation.dart';
import '../repositories/cart_repository.dart';
import '../repositories/product_repository.dart';
import '../core/network/api_client.dart';

class CartService extends ChangeNotifier {
  CartService._internal();
  static final CartService instance = CartService._internal();

  final List<Map<String, dynamic>> _items = [];
  String? userId;
  final CartRepository _repo = CartRepository();

  /// Initialize by loading server cart (call this once from app startup if desired)
  Future<void> loadFromServer() async {
    try {
      final data = await _repo.getCart();
      if (data.isNotEmpty) {
        userId = data['userId']?.toString();
        final items = data['items'];
        _items.clear();
        if (items is List) {
          // Convert raw items and enrich with product details (name, pricePerDay)
          final rawItems = <Map<String, dynamic>>[];
          for (final it in items) {
            if (it is Map) rawItems.add(Map<String, dynamic>.from(it));
          }

          // Fetch product details for unique equipmentIds
          final ids = rawItems.map((e) => (e['equipmentId'] ?? e['id']) as dynamic).where((e) => e != null).toSet();
          final productRepo = ProductRepository(apiClient: ApiClient());
          final Map<dynamic, Map<String, dynamic>?> productCache = {};
          for (final id in ids) {
            try {
              if (id is int) productCache[id] = await productRepo.getById(id);
            } catch (_) {
              productCache[id] = null;
            }
          }

          for (final it in rawItems) {
            final enriched = Map<String, dynamic>.from(it);
            final id = (it['equipmentId'] ?? it['id']);
            final pd = id != null && productCache.containsKey(id) ? productCache[id] : null;
            if (pd != null) {
              enriched['name'] = pd['name'] ?? pd['title'] ?? enriched['name'];
              enriched['pricePerDay'] = pd['pricePerDay'] ?? pd['price'] ?? enriched['pricePerDay'];
              enriched['image'] = (pd['imageResponses'] is List && (pd['imageResponses'] as List).isNotEmpty) ? (pd['imageResponses'][0]['imageUrl']) : enriched['image'];
            }
            _items.add(enriched);
          }
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  List<Map<String, dynamic>> get items => List.unmodifiable(_items);

  void addItem(Map<String, dynamic> item) {
    final newItem = Map<String, dynamic>.from(item);
    newItem['quantity'] = (newItem['quantity'] ?? 1);

    // Build payload expected by backend
    final payload = {
      'equipmentId': newItem['equipmentId'] ?? newItem['id'] ?? 0,
      'quantity': newItem['quantity'],
      // optional: if rental dates were selected on cart UI, include them in item
      'rentalStartDate': newItem['rentalStartDate'],
      'rentalEndDate': newItem['rentalEndDate'],
    };

    // Optimistically update local cache
    _items.add(newItem);
    notifyListeners();

    // Fire-and-forget API call to add item; on error reload from server to resync
    _repo.addItem(payload).catchError((_) async {
      await loadFromServer();
    });
  }

  void removeAt(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  double get total {
    double sum = 0;
    for (final it in _items) {
      final price = (it['pricePerDay'] ?? it['price'] ?? 0) as num;
      final qty = (it['quantity'] ?? 1) as num;
      sum += price.toDouble() * qty.toDouble();
    }
    return sum;
  }
}
