import '../core/network/api_client.dart';
import '../core/endpoints.dart';

class ProfileRepository {
  final _api = ApiClient();

  /// Returns a simple map with profile fields, or throws on error.
  Future<Map<String, dynamic>> getProfile() async {
    final data = await _api.getData(Endpoints.userMe);
    if (data is Map<String, dynamic>) return data;
    // If the API wraps data differently, try to coerce
    return {'data': data};
  }
}
