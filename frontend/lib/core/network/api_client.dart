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
      // Try to parse server error body into ApiResponseWrapper and create ApiException
      try {
        final status = e.response?.statusCode;
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          // Use the same wrapper to extract message/errors if present
          final wrapper = ApiResponseWrapper.fromMap(Map<String, dynamic>.from(data));
          final apiEx = ApiException(wrapper.message.isNotEmpty ? wrapper.message : 'API error', statusCode: wrapper.statusCode, errors: wrapper.errors);
          return handler.reject(DioException(requestOptions: e.requestOptions, error: apiEx));
        }
        if (status == 401) {
          final apiEx = ApiException('Unauthorized', statusCode: 401);
          return handler.reject(DioException(requestOptions: e.requestOptions, error: apiEx));
        }
      } catch (_) {
        // fallthrough to next
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
    // Some backend endpoints return an unwrapped object (e.g. { paymentUrl: '...' })
    // In that case return resp.data directly so callers expecting that shape can use it.
    if (resp.data is Map && (resp.data as Map).containsKey('paymentUrl')) {
      return resp.data;
    }
    final map = resp.data is Map ? Map<String, dynamic>.from(resp.data) : {'data': resp.data};
    // If the server didn't include a statusCode in the JSON wrapper, use the HTTP status code
    if (!map.containsKey('statusCode') && resp.statusCode != null) {
      map['statusCode'] = resp.statusCode;
    }
    final wrapper = ApiResponseWrapper.fromMap(map);
    if (wrapper.statusCode >= 200 && wrapper.statusCode < 300) return wrapper.data;
    final msg = wrapper.message.isNotEmpty ? wrapper.message : 'API error';
    throw ApiException(msg, statusCode: wrapper.statusCode, errors: wrapper.errors);
  }

  /// Convenience: performs POST and unwraps ApiResponse (generic)
  Future<dynamic> postData(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    final resp = await post(path, data: data, queryParameters: queryParameters);
    // Special-case: some endpoints (like Payment) return unwrapped objects
    // e.g. { paymentUrl: 'https://...' } - return resp.data directly
    if (resp.data is Map && (resp.data as Map).containsKey('paymentUrl')) {
      return resp.data;
    }
    final map = resp.data is Map ? Map<String, dynamic>.from(resp.data) : {'data': resp.data};
    // If the server didn't include a statusCode in the JSON wrapper, use the HTTP status code
    if (!map.containsKey('statusCode') && resp.statusCode != null) {
      map['statusCode'] = resp.statusCode;
    }
    final wrapper = ApiResponseWrapper.fromMap(map);
    if (wrapper.statusCode >= 200 && wrapper.statusCode < 300) return wrapper.data;
    final msg = wrapper.message.isNotEmpty ? wrapper.message : 'API error';
    throw ApiException(msg, statusCode: wrapper.statusCode, errors: wrapper.errors);
  }
}

