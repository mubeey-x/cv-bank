import 'package:fpdart/fpdart.dart';
import 'package:cv_bank/core/error/failures.dart';
import 'package:cv_bank/core/usecase/usecase.dart';
import '../entities/account.dart';
import '../repositories/auth_repository.dart';

class SignOut implements UseCase<Unit, NoParams> {
  final AuthRepository repository;
  const SignOut(this.repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) => repository.signOut();
}

class UpdateAccountName implements UseCase<Account, String> {
  final AuthRepository repository;
  const UpdateAccountName(this.repository);

  @override
  Future<Either<Failure, Account>> call(String name) async {
    final clean = name.trim();
    if (clean.isEmpty) {
      return left(const ValidationFailure('Name cannot be empty.'));
    }
    return repository.updateName(clean);
  }
}

class DeleteAccount implements UseCase<Unit, NoParams> {
  final AuthRepository repository;
  const DeleteAccount(this.repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) =>
      repository.deleteAccount();
}

/// Deliberately does NOT implement UseCase. Reading the restored
/// session is synchronous and cannot fail, so wrapping it in a

class GetCurrentAccount {
  final AuthRepository repository;
  const GetCurrentAccount(this.repository);

  Account? call() => repository.currentAccount;
}
