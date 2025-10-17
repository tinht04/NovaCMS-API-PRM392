import '../core/network/api_client.dart';
import '../core/endpoints.dart';

class CartRepository {
  final ApiClient _api = ApiClient();

  /// Get current cart. Returns the `data` object from API: { userId, items: [...] }
  Future<Map<String, dynamic>> getCart() async {
    final data = await _api.getData(Endpoints.cart);
    if (data is Map<String, dynamic>) return data;
    return {};
  }

  /// Add item to cart. Payload expected shape:
  /// { equipmentId, quantity, rentalStartDate, rentalEndDate }
  Future<dynamic> addItem(Map<String, dynamic> payload) async {
    final data = await _api.postData(Endpoints.cartAddItem, data: payload);
    return data;
  }
}
