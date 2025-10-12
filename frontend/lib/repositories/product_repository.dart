import '../core/network/api_client.dart';
import '../core/endpoints.dart';

class ProductRepository {
  final ApiClient apiClient;

  ProductRepository({required this.apiClient});

  Future<List<Map<String, dynamic>>> fetchProducts({Map<String, dynamic>? query}) async {
    final data = await apiClient.getData(Endpoints.equipments);
    // Some API responses wrap payload inside { data: { items: [...] } }
    if (data is Map && data.containsKey('items')) {
      final items = data['items'];
      if (items is List) return List<Map<String, dynamic>>.from(items.map((e) => Map<String, dynamic>.from(e as Map)));
    }
    // If API returns { data: { ... } } where items are in data['data']['items']
    if (data is Map && data.containsKey('data')) {
      final inner = data['data'];
      if (inner is Map && inner.containsKey('items')) {
        final items = inner['items'];
        if (items is List) return List<Map<String, dynamic>>.from(items.map((e) => Map<String, dynamic>.from(e as Map)));
      }
    }
    // Fallback: if data is a list
    if (data is List) {
      return List<Map<String, dynamic>>.from(data.map((e) => Map<String, dynamic>.from(e as Map)));
    }
    return [];
  }

  Future<Map<String, dynamic>?> getById(int id) async {
    final data = await apiClient.getData(Endpoints.equipmentById(id));
    // API may return wrapper { data: { ... } }
    if (data is Map && data.containsKey('data')) {
      final inner = data['data'];
      if (inner is Map<String, dynamic>) return inner;
    }
    if (data is Map<String, dynamic>) return data;
    return null;
  }
}
