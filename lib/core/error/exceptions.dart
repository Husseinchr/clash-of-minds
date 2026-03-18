/// Base exception class
class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() => message;
}

/// Server exception
class ServerException extends AppException {
  ServerException(super.message);
}

/// Cache exception
class CacheException extends AppException {
  CacheException(super.message);
}

/// Network exception
class NetworkException extends AppException {
  NetworkException(super.message);
}

/// Authentication exception
class AuthException extends AppException {
  AuthException(super.message);
}

/// Validation exception
class ValidationException extends AppException {
  ValidationException(super.message);
}
