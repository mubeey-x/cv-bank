import 'package:cv_bank/core/error/failures.dart';
import 'package:cv_bank/core/usecase/usecase.dart';
import 'package:cv_bank/core/utils/validators.dart';
import 'package:cv_bank/features/auth/domain/entities/sign_up_outcome.dart';
import 'package:cv_bank/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class SignUpParams {
  final String name;
  final String email;
  final String password;

  const SignUpParams({
    required this.name,
    required this.email,
    required this.password,
  });
}

class SignUp implements UseCase<SignUpOutcome, SignUpParams> {
  final AuthRepository repository;
  const SignUp(this.repository);

  @override
  Future<Either<Failure, SignUpOutcome>> call(SignUpParams params) async {
    final name = params.name.trim();
    final email = params.email.trim().toLowerCase();

    if (!Validators.isNotBlank(name)) {
      return left(const ValidationFailure('Enter your name.'));
    }
    if (!Validators.isEmail(email)) {
      return left(const ValidationFailure('Enter a valid email address.'));
    }
    if (!Validators.isPassword(params.password)) {
      return left(
        const ValidationFailure('Password must be at least 8 characters.'),
      );
    }

    return repository.signUp(
      name: name,
      email: email,
      password: params.password,
    );
  }
}
