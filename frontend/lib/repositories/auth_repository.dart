import '../core/network/api_client.dart';
import '../core/endpoints.dart';
import '../core/secure_storage.dart';

class AuthRepository {
  final ApiClient _api;
  final SecureStorage _storage;
  final Future<dynamic> Function(String path, {dynamic data, Map<String, dynamic>? queryParameters})? postDataFn;

  AuthRepository({ApiClient? apiClient, SecureStorage? storage, this.postDataFn}) : _api = apiClient ?? ApiClient(), _storage = storage ?? const FlutterSecureStorageWrapper();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final payload = {'email': email, 'password': password};
  final raw = postDataFn != null ? await postDataFn!(Endpoints.login, data: payload) : await _api.postData(Endpoints.login, data: payload);
  final data = raw;
    // Expect backend ApiResponse.data is UserLoginResponse: contains AccessToken & RefreshToken
    if (data is Map<String, dynamic>) {
      final token = data['accessToken'] ?? data['AccessToken'] ?? data['access_token'];
      final refresh = data['refreshToken'] ?? data['RefreshToken'] ?? data['refresh_token'];
      if (token != null) await _storage.write(key: 'access_token', value: token.toString());
      if (refresh != null) await _storage.write(key: 'refresh_token', value: refresh.toString());
    }
    return data as Map<String, dynamic>;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<String?> getAccessToken() => _storage.read(key: 'access_token');

  Future<Map<String, dynamic>> register(String fullName, String email, String password) async {
    final payload = {'fullName': fullName, 'email': email, 'passwordHash': password, 'roleId': 3};
    final raw = postDataFn != null ? await postDataFn!(Endpoints.register, data: payload) : await _api.postData(Endpoints.register, data: payload);
    final data = raw;
    if (data is Map<String, dynamic>) {
      // try to persist token if returned
      final token = data['accessToken'] ?? data['AccessToken'] ?? data['access_token'];
      final refresh = data['refreshToken'] ?? data['RefreshToken'] ?? data['refresh_token'];
      if (token != null) await _storage.write(key: 'access_token', value: token.toString());
      if (refresh != null) await _storage.write(key: 'refresh_token', value: refresh.toString());
    }
    return data as Map<String, dynamic>;
  }
}
