import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../env.dart';
import 'response_wrapper.dart';
import 'exceptions.dart';

final _secureStorage = const FlutterSecureStorage();

/// Minimal ApiClient wrapper around Dio with Authorization header support.
class ApiClient {
  final Dio dio;

  ApiClient._internal(this.dio);

  factory ApiClient() {
  final dio = Dio(BaseOptions(baseUrl: Env.apiBaseUrl, connectTimeout: const Duration(seconds: 30), receiveTimeout: const Duration(seconds: 30)));

    // Remove automatic request/response body logging to keep logs clean in development.

  // Authorization interceptor - placeholder reads from secure storage
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) async {
      // Read token from secure storage and attach
      try {
        final token = await _secureStorage.read(key: 'access_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      } catch (_) {}
      return handler.next(options);
    }, onError: (e, handler) async {
      // If the server returns HTTP 401, wrap into an UnauthorizedException so callers can handle login flow
      final status = e.response?.statusCode;
      if (status == 401) {
        // wrap into a DioException so callers can detect and react
        final dioEx = DioException(requestOptions: e.requestOptions, error: UnauthorizedException('Unauthorized'));
        return handler.reject(dioEx);
      }
      return handler.next(e);
    }));

    return ApiClient._internal(dio);
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) {
    return dio.get(path, queryParameters: queryParameters, options: options);
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return dio.post(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return dio.put(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> patch(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return dio.patch(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return dio.delete(path, data: data, queryParameters: queryParameters, options: options);
  }

  /// Convenience: performs GET and unwraps ApiResponse (generic)
  Future<dynamic> getData(String path, {Map<String, dynamic>? queryParameters}) async {
    final resp = await get(path, queryParameters: queryParameters);
    final map = resp.data is Map ? Map<String, dynamic>.from(resp.data) : {'data': resp.data};
    final wrapper = ApiResponseWrapper.fromMap(map);
    if (wrapper.statusCode >= 200 && wrapper.statusCode < 300) return wrapper.data;
    throw Exception('${wrapper.message} ${wrapper.errors.join(', ')}');
  }

  /// Convenience: performs POST and unwraps ApiResponse (generic)
  Future<dynamic> postData(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    final resp = await post(path, data: data, queryParameters: queryParameters);
    final map = resp.data is Map ? Map<String, dynamic>.from(resp.data) : {'data': resp.data};
    final wrapper = ApiResponseWrapper.fromMap(map);
    if (wrapper.statusCode >= 200 && wrapper.statusCode < 300) return wrapper.data;
    throw Exception('${wrapper.message} ${wrapper.errors.join(', ')}');
  }
}

