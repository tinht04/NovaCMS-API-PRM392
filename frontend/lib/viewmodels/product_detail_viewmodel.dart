import 'package:flutter/foundation.dart';
import '../repositories/product_repository.dart';
import '../services/cart_service.dart';
import '../services/notification_service.dart';
import '../core/navigation.dart';

class ProductDetailViewModel extends ChangeNotifier {
  final ProductRepository _repo;

  bool loading = true;
  String? error;
  Map<String, dynamic>? item;
  int currentImageIndex = 0;
  bool isFavorite = false;

  // Keep MVVM separation: viewmodels may create repositories by default
  // but UI should not import networking primitives. Tests can inject
  // a fake ProductRepository when needed.
  ProductDetailViewModel([ProductRepository? repo]) : _repo = repo ?? ProductRepository();

  /// Add the currently loaded item to cart with rental dates.
  /// Returns true if added successfully, false otherwise.
  Future<bool> addToCart(DateTime start, DateTime end) async {
    if (item == null) return false;
    try {
      final cartItem = Map<String, dynamic>.from(item!);
      cartItem['rentalStartDate'] = start.toUtc().toIso8601String();
      cartItem['rentalEndDate'] = end.toUtc().toIso8601String();
      CartService.instance.addItem(cartItem);
      final productName = item?['name'] ?? item?['equipmentName'] ?? 'Product';
      // Provide an onTap that navigates to the cart using the global navigator key.
      NotificationService.instance.add('Added "$productName" to cart!', onTap: () {
        try {
          navigatorKey.currentState?.pushNamed('/cart');
        } catch (_) {}
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> load(int id) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      item = await _repo.getById(id);
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  void setImageIndex(int i) {
    currentImageIndex = i;
    notifyListeners();
  }

  void toggleFavorite() {
    isFavorite = !isFavorite;
    notifyListeners();
  }
}
