import 'package:fpdart/fpdart.dart';
import 'package:cv_bank/core/error/failures.dart';
import 'package:cv_bank/core/usecase/usecase.dart';
import '../entities/account.dart';
import '../repositories/auth_repository.dart';

class VerifySignUpParams {
  final String email;
  final String token;

  const VerifySignUpParams({required this.email, required this.token});
}

class VerifySignUp implements UseCase<Account, VerifySignUpParams> {
  final AuthRepository repository;
  const VerifySignUp(this.repository);

  @override
  Future<Either<Failure, Account>> call(VerifySignUpParams params) async {
    final token = params.token.trim();
    if (token.length != 6) {
      return left(const ValidationFailure('Enter the 6-digit code.'));
    }
    return repository.verifySignUp(
      email: params.email.trim().toLowerCase(),
      token: token,
    );
  }
}

class ResendSignUpCode implements UseCase<Unit, String> {
  final AuthRepository repository;
  const ResendSignUpCode(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String email) =>
      repository.resendSignUpCode(email: email.trim().toLowerCase());
}
