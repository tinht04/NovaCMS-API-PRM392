import '../core/network/api_client.dart';
import '../core/endpoints.dart';

class CategoryRepository {
  final ApiClient _api = ApiClient();

  Future<List<Map<String, dynamic>>> getAll() async {
    final data = await _api.getData(Endpoints.categories);
    // Expecting wrapper { data: [ ... ] } or direct list
    if (data is List) return List<Map<String, dynamic>>.from(data.map((e) => Map<String, dynamic>.from(e as Map)));
    if (data is Map && data.containsKey('data') && data['data'] is List) return List<Map<String, dynamic>>.from((data['data'] as List).map((e) => Map<String, dynamic>.from(e as Map)));
    return [];
  }
}
