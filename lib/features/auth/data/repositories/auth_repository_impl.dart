import 'package:cv_bank/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fpdart/fpdart.dart';

import 'package:cv_bank/core/error/exceptions.dart';
import 'package:cv_bank/core/error/failures.dart';
import 'package:cv_bank/core/error/guard.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/sign_up_outcome.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  const AuthRepositoryImpl({required this.remote});

  @override
  Account? get currentAccount => remote.currentAccount;

  @override
  Stream<Account?> get accountChanges => remote.accountChanges;

  @override
  Future<Either<Failure, Account>> signIn({
    required String email,
    required String password,
  }) => _guardAuth(() => remote.signIn(email, password));

  @override
  Future<Either<Failure, SignUpOutcome>> signUp({
    required String name,
    required String email,
    required String password,
  }) => _guardAuth(() async {
    final account = await remote.signUp(name, email, password);
    return account == null
        ? SignUpOutcome.verificationRequired
        : SignUpOutcome.signedIn;
  });

  @override
  Future<Either<Failure, Account>> verifySignUp({
    required String email,
    required String token,
  }) => _guardAuth(() => remote.verifySignUp(email, token));

  @override
  Future<Either<Failure, Unit>> resendSignUpCode({required String email}) =>
      _guardAuth(() async {
        await remote.resendSignUpCode(email);
        return unit;
      });

  @override
  Future<Either<Failure, Unit>> requestPasswordReset({required String email}) =>
      _guardAuth(() async {
        await remote.requestPasswordReset(email);
        return unit;
      });

  @override
  Future<Either<Failure, Account>> confirmPasswordReset({
    required String email,
    required String token,
    required String newPassword,
  }) =>
      _guardAuth(() => remote.confirmPasswordReset(email, token, newPassword));

  @override
  Future<Either<Failure, Account>> updateName(String name) =>
      guard(() => remote.updateName(name));

  @override
  Future<Either<Failure, Unit>> signOut() => guard(() async {
    await remote.signOut();
    return unit;
  });

  /// Auth needs its own mapping, because the generic AuthFailure
  /// message ("Please sign in again") makes no sense on a login form.
  Future<Either<Failure, T>> _guardAuth<T>(Future<T> Function() action) async {
    try {
      return right(await action());
    } on UnauthorizedException catch (e) {
      return left(_translate(e.message));
    } on AppException catch (e) {
      return left(e.toFailure());
    } catch (_) {
      return left(const UnknownFailure());
    }
  }

  Failure _translate(String raw) {
    final m = raw.toLowerCase();

    if (m.contains('invalid login credentials')) {
      // Deliberately vague. Saying which half was wrong tells an
      // attacker which emails are registered.
      return const AuthFailure('Incorrect email or password.');
    }
    if (m.contains('email not confirmed')) {
      return const EmailNotConfirmedFailure();
    }
    if (m.contains('already registered') || m.contains('already exists')) {
      return const AccountExistsFailure();
    }
    if (m.contains('token has expired') ||
        m.contains('invalid token') ||
        m.contains('otp')) {
      return const AuthFailure('That code is wrong or has expired.');
    }
    if (m.contains('rate limit') || m.contains('too many')) {
      return const AuthFailure('Too many attempts. Wait a minute and retry.');
    }
    if (m.contains('password should be')) {
      return const ValidationFailure('Password must be at least 8 characters.');
    }
    return const AuthFailure('Could not sign you in. Please try again.');
  }
}
