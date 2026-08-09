import 'package:fpdart/fpdart.dart';

import 'package:cv_bank/core/error/failures.dart';
import 'package:cv_bank/core/usecase/usecase.dart';
import 'package:cv_bank/core/utils/validators.dart';
import '../entities/account.dart';
import '../repositories/auth_repository.dart';

class SignInParams {
  final String email;
  final String password;

  const SignInParams({required this.email, required this.password});
}

class SignIn implements UseCase<Account, SignInParams> {
  final AuthRepository repository;
  const SignIn(this.repository);

  @override
  Future<Either<Failure, Account>> call(SignInParams params) async {
    final email = params.email.trim().toLowerCase();

    if (!Validators.isEmail(email)) {
      return left(const ValidationFailure('Enter a valid email address.'));
    }
    if (params.password.isEmpty) {
      return left(const ValidationFailure('Enter your password.'));
    }

    return repository.signIn(email: email, password: params.password);
  }
}
