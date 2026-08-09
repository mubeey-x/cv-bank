import 'package:fpdart/fpdart.dart';

import 'package:cv_bank/core/error/failures.dart';
import 'package:cv_bank/core/usecase/usecase.dart';
import 'package:cv_bank/core/utils/validators.dart';
import '../entities/account.dart';
import '../repositories/auth_repository.dart';

class RequestPasswordReset implements UseCase<Unit, String> {
  final AuthRepository repository;
  const RequestPasswordReset(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String email) async {
    final clean = email.trim().toLowerCase();
    if (!Validators.isEmail(clean)) {
      return left(const ValidationFailure('Enter a valid email address.'));
    }
    return repository.requestPasswordReset(email: clean);
  }
}

class ConfirmPasswordResetParams {
  final String email;
  final String token;
  final String newPassword;

  const ConfirmPasswordResetParams({
    required this.email,
    required this.token,
    required this.newPassword,
  });
}

class ConfirmPasswordReset
    implements UseCase<Account, ConfirmPasswordResetParams> {
  final AuthRepository repository;
  const ConfirmPasswordReset(this.repository);

  @override
  Future<Either<Failure, Account>> call(
    ConfirmPasswordResetParams params,
  ) async {
    if (params.token.trim().length != 6) {
      return left(const ValidationFailure('Enter the 6-digit code.'));
    }
    if (!Validators.isPassword(params.newPassword)) {
      return left(
        const ValidationFailure('Password must be at least 8 characters.'),
      );
    }
    return repository.confirmPasswordReset(
      email: params.email.trim().toLowerCase(),
      token: params.token.trim(),
      newPassword: params.newPassword,
    );
  }
}
