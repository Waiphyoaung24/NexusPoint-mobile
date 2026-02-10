class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final bool isRetryable;

  ApiException(
    this.message, {
    this.statusCode,
    this.isRetryable = false,
  });

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

class NetworkException extends ApiException {
  NetworkException(super.message) : super(isRetryable: true);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException() : super('Unauthorized', statusCode: 401);
}

class ForbiddenException extends ApiException {
  ForbiddenException() : super('Access denied', statusCode: 403);
}

class ServerException extends ApiException {
  ServerException(super.message) : super(isRetryable: true);
}
