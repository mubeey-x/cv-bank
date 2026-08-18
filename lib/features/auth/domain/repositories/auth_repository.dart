import 'package:fpdart/fpdart.dart';

import 'package:cv_bank/core/error/failures.dart';
import '../entities/account.dart';
import '../entities/sign_up_outcome.dart';

abstract interface class AuthRepository {
  /// Synchronous, read from the restored session. Null when signed out.
  Account? get currentAccount;

  /// Emits on sign-in, sign-out and token refresh.
  Stream<Account?> get accountChanges;

  Future<Either<Failure, Account>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, SignUpOutcome>> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, Account>> verifySignUp({
    required String email,
    required String token,
  });

  Future<Either<Failure, Unit>> resendSignUpCode({required String email});

  Future<Either<Failure, Unit>> requestPasswordReset({required String email});

  Future<Either<Failure, Account>> confirmPasswordReset({
    required String email,
    required String token,
    required String newPassword,
  });

  Future<Either<Failure, Account>> updateName(String name);

  Future<Either<Failure, Unit>> deleteAccount();

  Future<Either<Failure, Unit>> signOut();
}
