sealed class Failure {
  final String message;
  final String? debug;

  const Failure(this.message, {this.debug});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() => '$runtimeType: $message';
}

final class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Something went wrong. Please try again.',
  ]);
}

final class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'No internet connection. Check your data and try again.',
  ]);
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Could not read saved data.']);
}

final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Please sign in again.']);
}

final class DuplicateFailure extends Failure {
  const DuplicateFailure([
    super.message = 'This person is already in your list.',
  ]);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found.']);
}

final class FileFailure extends Failure {
  const FileFailure([super.message = 'open that file.']);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([
    super.message = 'Something went wrong. Please try again.',
  ]);
}

/// Login screen should offer to resend the code and route to OTP.
final class EmailNotConfirmedFailure extends Failure {
  const EmailNotConfirmedFailure([
    super.message = 'Confirm your email to continue.',
  ]);
}

/// Register screen should offer a link to sign in.
final class AccountExistsFailure extends Failure {
  const AccountExistsFailure([
    super.message = 'An account with this email already exists.',
  ]);
}
