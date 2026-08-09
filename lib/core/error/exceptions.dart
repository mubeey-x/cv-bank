sealed class AppException implements Exception {
  final String message;
  final String? code;
  final Object? cause;

  const AppException(this.message, {this.code, this.cause});

  @override
  String toString() => '$runtimeType(${code ?? '-'}): $message';
}

final class ServerException extends AppException {
  const ServerException(super.message, {super.code, super.cause});
}

final class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

final class CacheException extends AppException {
  const CacheException(super.message, {super.cause});
}

final class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message, {super.code, super.cause});
}

final class DuplicateException extends AppException {
  const DuplicateException(super.message, {super.code, super.cause});
}

final class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.code});
}

final class FileException extends AppException {
  const FileException(super.message, {super.code, super.cause});
}
