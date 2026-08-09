import 'package:fpdart/fpdart.dart';
import 'exceptions.dart';
import 'failures.dart';

Future<Either<Failure, T>> guard<T>(Future<T> Function() action) async {
  try {
    return right(await action());
  } on AppException catch (e) {
    return left(e.toFailure());
  } catch (e) {
    return left(UnknownFailure());
  }
}

extension AppExceptionX on AppException {
  Failure toFailure() => switch (this) {
    NetworkException() => const NetworkFailure(),
    CacheException() => const CacheFailure(),
    UnauthorizedException() => const AuthFailure(),
    DuplicateException() => const DuplicateFailure(),
    NotFoundException() => const NotFoundFailure(),
    FileException() => const FileFailure(),
    ServerException() => const ServerFailure(),
  };
}
