class ApiResponseWrapper<T> {
  final int statusCode;
  final String message;
  final T? data;
  final List<String> errors;

  ApiResponseWrapper({required this.statusCode, required this.message, this.data, List<String>? errors}) : errors = errors ?? [];

  factory ApiResponseWrapper.fromMap(Map<String, dynamic> map) {
    return ApiResponseWrapper(
      statusCode: map['statusCode'] ?? 200,
      message: map['message'] ?? '',
      data: map['data'],
      errors: (map['errors'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
