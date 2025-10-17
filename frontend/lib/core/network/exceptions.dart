class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = 'Unauthorized']);
  @override
  String toString() => 'UnauthorizedException: $message';
}

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final List<String> errors;

  ApiException(this.message, {this.statusCode, this.errors = const []});

  @override
  String toString() => 'ApiException(${statusCode ?? 'N/A'}): $message ${errors.isNotEmpty ? errors.join(', ') : ''}';
}
